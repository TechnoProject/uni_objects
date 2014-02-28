#encoding: utf-8

require 'pp'

class UniObjects::UniVerse
  @@server = 'localhost'
  @@user = 'user'
  @@password = 'passwd'
  @@account = '/usr/uv/UVUSR'

  @@nls_map = 'UTF8'
  @@charcode = 'UTF-8' # 回避策
  @@original_charcode = 'MS932' # 回避策
  @@MAP = {"@ID" => "id"}

  class << self

    def init_session
      @@session = nil
    end

    def open_session
      @@session = UniObjects::open(@@server,@@user,@@password,@@account)
    end

    def quit_session
      @@session.quit
    end

    def table_name
      @table_name || set_table_name(self.to_s.split('::').last.pluralize.upcase)
    end

    def set_table_name(name)
      return false unless name
      @table_name = name
    end

    def fields
      @fields || set_fields
    end

    def set_fields
      temp = UniObjects::UniVerse.get_hash_from_list_command('LIST DICT ' + @table_name + ' "@"')
      @fields = temp[@table_name]['FIELD.DEF_MV']['FIELD.DEF'].split(' ')
      
      # フィールド一覧の設定
      class_eval { attr_accessor :id }
      @fields.each do |field|
        attr_name = @@MAP[field] || field.downcase
        class_eval { attr_accessor attr_name }
      end
    end

    def all( options={} )
      cmd_opts = ""
      cmd_opts += " " + options[:fields].to_s if options[:fields]
      cmd_opts += " WITH " + options[:with].to_s if options[:with]
      cmd_opts += " WHEN " + options[:when].to_s if options[:when]
      cmd_opts += " SAMPLE " + options[:limit].to_s if options[:limit]
      cmd_opts += " " + options[:options].to_s if options[:options]

      result = []
      root = get_hash_from_list_command('LIST ' + table_name + cmd_opts)
      begin
        items = root[table_name]
        if items.class==Hash  # １レコードの時
          result << __send__( "new", items )
        else                      # 複数レコードのとき
          items.each do |item|
            result << __send__( "new", item )
          end
        end
      rescue
      end
      result
    end

    def first(options={})
      cmd_opts = ""
      cmd_opts += " " + options[:fields] if options[:fields]
      cmd_opts += " WITH " + options[:with] if options[:with]
      cmd_opts += " WHEN " + options[:when] if options[:when]
      cmd_opts += " " + options[:options] if options[:options]

      result = nil
      root = get_hash_from_list_command('LIST ' + table_name + cmd_opts + ' FIRST 1')
      return nil if root.nil?
      result = __send__( "new", root[table_name] )
    end

    def find(options=nil)
      case options
      when Hash
        opts = options.dup
        if options[:id]
          opts[:options] = "\"#{opts[:id]}\""
          uni_verse = (first opts)
          raise UniObjects::UniError.new(UniObjects::IE_IID, "record not found.") unless uni_verse
          return uni_verse
        else
          return nil if (all options).empty?
          all options
        end
      else
        first :options => "\"#{options}\""
      end
    end

    def get_hash_from_list_command(command)
      xml = perform_command(command + ' TOXML')
      xml = xml.gsub(/\A[^<]+/,'').gsub(/<\/ROOT>[^\z]+\z/,"</ROOT>").gsub(@@original_charcode,@@charcode)
      #pp xml
      root = Hash.from_xml( xml )
      root["ROOT"]
    end

    def perform_command(command)
      xml = nil
      #@@session.execute('SET.TERM.TYPE MAP '+@@nls_map)#xmlの文字コード指定が正常にできるなら不要
      @@session.set_map(@@nls_map)
      xml = @@session.execute( command + ' TOXML' )
      while t = @@session.executecontinue() do
        xml += t
      end
      xml
    end

    def create( attributes={} )
      uni_verse = self.new(attributes)
      uni_verse.save
    end

    def update(attributes={})
      uni_verse = find( attributes[:id] )
      uni_verse.update_attributes( attributes )
    end

    def destroy(id)
      uni_verse = find(id)
      uni_verse.destroy if uni_verse
      true
    end

  end

  def initialize( hash={} )
    # テーブル名、フィールド名の設定
    @table_name = self.class.table_name
    @fields = self.class.fields
    
    # 値設定
    if hash
      instance_variable_set( "@id", hash["_ID"])
      hash.each do |field,value|
        attr_name = @@MAP[field] || field.downcase
        instance_variable_set( "@#{attr_name}", value)
        class_eval { attr_accessor attr_name }
      end
    end
  end

  def to_s
    @id
  end

  def save
    @@session.open(@table_name) do |file|
      # 更新の場合は該当するレコードIDのデータを取得する
      dynarray = nil
      if self.new_record?
        dynarray = UniObjects::UniDynArray.new("\xEF\xA3\xBE")
        init_dynarray = UniObjects::UniDynArray.new("\xEF\xA3\xBE")
      else
        dynarray = UniObjects::UniDynArray.new(file.read(@id))
        init_dynarray = UniObjects::UniDynArray.new(file.read(@id))
      end
      
      # 更新するレコードを作成する
      @@session.execute('SELECT DICT '+ @table_name)
      @@session.opendict(@table_name) do |dictfile|
        @@session.each do |column|
          unless column == "@ID"
            if dictfile.readfield(column,1)=="D"
              # マルチバリュー未対応
              #if dictfile.readfield(column, 6)=="S"
                value_number = 0
              #else
              #  value_number = 0
              #end
              column_value = instance_variable_get("@#{column}".downcase) || ""
              dynarray.replace(column_value, dictfile.readfield(column,2).to_i, value_number) unless column_value.empty?
            end
          end
        end
      end
      
      # レコードを更新する
      begin
        return false if dynarray.to_s == init_dynarray.to_s
        file.write(@id, dynarray.to_s)
        return true
      rescue => e
        return false if e.is_a?(UniObjects::UniError)
        raise e
      end
    end
  end

  def new_record?
    return false if self.class.find(self.id)
    true
  end

  def update_attributes( attributes={} )
    attributes.each { |key, value|
      instance_variable_set("@#{key}", value)
    }
    save
  end

  def update_attribute( name, value )
    file = @@session.open(@table_name)
    dictfile = @@session.opendict(@table_name)
    begin
      file.writefield(@id, dictfile.readfield(name.upcase,2).to_i, value)
      return true
    rescue => e
      return false if e.is_a?(UniObjects::UniError)
      raise e
    end
  end

  def destroy
    @@session.open(@table_name) do |file|
      begin
        file.deleterecord(@id)
        return true
      rescue => e
        if e.is_a?(UniObjects::UniError)
          return true if e.code == UniObjects::IE_RNF
          return false
        end
        raise e
      end
    end
  end

end
