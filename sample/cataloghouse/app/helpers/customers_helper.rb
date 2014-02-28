#encoding: UTF-8

module CustomersHelper

  def show_gender(gender)
    {"1"=>"男","2"=>"女","3"=>"不明"}[gender] || "(不明)"
  end

  def show_dob(dob)
    /^(19|20)[0-9][0-9][01][0-9][0123][0-9]$/.match(dob) ? dob.insert(6,"/").insert(4,"/") : "不明"
  end

  def show_receive(receive)
    result = ""
    result += "<td>#{receive["RECEIVE_IDS"]}</td>\r\n"
    result += "<td>#{receive["SPFL"]}</td>\r\n"
    result += "<td>#{receive["SEQ"]}</td>\r\n"
    result += "<td>#{receive["ITEM_ID"]}</td>\r\n"
    result += "<td>#{receive["COLOR_SIZE1"]}</td>\r\n"
    result += "<td>#{receive["COLOR_SIZE2"]}</td>\r\n"
    result += "<td>#{receive["RECEIVE_CODE"]}</td>\r\n"
    result
  end

  def show_receives(a1_ms)
    result = ""
    receives = a1_ms["A1_MS"]
    receives = [receives] unless receives.class == Array
    receives.each.with_index do |receive,i|
      result += "<tr>\r\n"
      result += show_receive(receive)
      result += "</tr>\r\n"
    end
    result
  end

  def show_a1_mv(a1_mv)
    result = ""
    case a1_mv
    when Array
      for a1_ms in a1_mv
        result += show_receives(a1_ms)
      end
    else
      result += show_receives(a1_mv)
    end
    result
  end

end
