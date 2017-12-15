class Report

  def self.open_sto_list(lifnr, bukrs)
    sql = "
    select a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh) netpr, b.menge,b.meins,c.eindt,
           sum(c.menge-c.wemng) balqty, sum(c.glmng) dlvqty, sum(c.wemng) rcvqty, sum(c.glmng-c.wemng) otwqty
      from sapsr3.ekko a
        join sapsr3.ekpo b on b.mandt=a.mandt and b.ebeln=a.ebeln and b.elikz=' ' and b.loekz=' '
        join sapsr3.eket c on c.mandt=b.mandt and c.ebeln=b.ebeln and c.ebelp=b.ebelp and c.menge <> 0
      where a.mandt='168' and a.lifnr=? and a.bukrs=?
      group by a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh), b.menge,b.meins, c.eindt
      having sum(c.menge-c.wemng) <> 0
      order by a.bedat
    "
    Sapdb.find_by_sql([sql, lifnr, bukrs])
  end

  def self.stock_idle_report(fl, email)
    sql = "
      select
             a.matnr,a.charg,b.review_date,b.reason,to_char(b.remark) remark,a.werks,
             a.fl,a.pl,a.sr,sum(a.idle_qty) idle_qty, sum(a.idle_amt) idle_amt,a.stk_aged,a.stk_cat,a.matkl,a.mtart,a.maktx,
             a.mo,a.po,a.supplier,a.ekgrp,a.moq,a.safety,a.mrp_grp,a.mb51,b.created_at
        from tmplum.stk_report a
          left join tmplum.stk_idle b on b.matnr=a.matnr and b.charg=a.charg
        where a.idle_qty > 0 /* and nvl(reason,' ') = ' '*/ and a.fl = ?
        group by a.matnr,a.charg,b.review_date,b.reason,to_char(b.remark),a.werks,
             a.fl,a.pl,a.sr,a.stk_aged,a.stk_cat,a.matkl,a.mtart,a.maktx,
             a.mo,a.po,a.supplier,a.ekgrp,a.moq,a.safety,a.mrp_grp,a.mb51,b.created_at
        order by nvl(reason,' '),b.created_at desc
    "
    rows = Sapdb.find_by_sql([sql, fl])
    excel = Excel.resultset(rows)
    filename = "log/#{SecureRandom.hex}.xlsx"
    excel.serialize(filename)
    Mail.defaults do
      delivery_method :smtp, address: '172.91.1.253', port: 25
    end

    Mail.deliver do
      from 'lum.cl@l-e-i.com'
      to email
      subject '呆料明細報表 Idle Stock Detail Report'
      body 'warehouse::app::models::report::stock_idle_report'
      add_file filename: filename
    end
    File.delete(filename)
  end

  def self.update_stock_idle(datas, email)
    # 0    1   2       3       4
    # 料號 批次 處理日期 原因代碼 原因說明
    # review_date(監視日期)	reason(原因)	remark(說明)
    fails = []
    datas.each do |row|
      fields = []
      buf = row.split("\t")
      if buf.size > 2
        fields.append("review_date='#{buf[2]}'") if buf[2].present?
        fields.append("reason='#{stock_idle_reason(buf[3])}'") if buf[3].present?
        fields.append("vbeln='#{buf[4]}'") if buf[4].present?
        if fields.present?
          sql = "update tmplum.stk_idle set #{fields.join(',')} where matnr='#{buf[0]}' and charg='#{buf[1]}'"
          if Sapdb.connection.execute(sql) == 0
            fails.append("#{buf[0]} #{buf[1]} 更新失败 Update Fail")
          end
        end
      end
    end

    Mail.defaults do
      delivery_method :smtp, address: '172.91.1.253', port: 25
    end

    if fails.present?
      body = fails.join("\n")
    else
      body = "全部更新完畢. Update Finish"
    end

    Mail.deliver do
      from 'lum.cl@l-e-i.com'
      to email
      subject '呆料原因更新報告 Idle Stock Reason Update Report'
      body "#{body}\n\nwarehouse::app::models::report::stock_idle_report"
    end
  end

  def self.stock_idle_reason(reason)
    return "A 業務訂單Cancel" if reason[0].eql?('A')
    return "B RO備料/策略備料" if reason[0].eql?('B')
    return "C ECR修改" if reason[0].eql?('C')
    return "D 最小包裝" if reason[0].eql?('D')
    return "E 最小訂購量" if reason[0].eql?('E')
    return "F 其他" if reason[0].eql?('F')
    return "G 半成品/成品" if reason[0].eql?('G')
    return ""
  end


  def self.po_schedule_check
    Mail.defaults do
      delivery_method :smtp, address: '172.91.1.253', port: 25
    end
    from = 'ips'
    to = 'felix.jiang@l-e-i.com,lum.cl@l-e-i.com,ted.meng@l-e-i.com'

    sql = "
    select b.ebeln
      from sapsr3.zsd0012@sapp a
        join sapsr3.ekko@sapp b on b.mandt='168' and b.ebeln=a.delnr and b.bsart not in ('Z006','Z008')
      where a.delkz in ('BE','LA')
    minus
    select ebeln from it.poschedule
  "
    rows = Sapcodb.find_by_sql(sql)
    if rows.present?
      subject = "IT.POSCHEDULE 異常 - #{rows.count} 筆PO沒有計算! 是否要停機?"
      excel = Excel.resultset(rows)
      filename = "log/#{SecureRandom.hex}.xlsx"
      excel.serialize(filename)
      Mail.deliver do
        from from
        to to
        subject subject
        body 'warehouse::app::models::report::po_schedule_check'
        add_file filename: filename
      end
      File.delete(filename)
    else
      Mail.deliver do
        from from
        to to
        subject "IT.POSCHEDULE 正常"
        body 'warehouse::app::models::report::po_schedule_check'
      end
    end
  end

  def self.ekes_check
    Mail.defaults do
      delivery_method :smtp, address: '172.91.1.253', port: 25
    end

    from = 'sap'
    to = 'lum.cl@l-e-i.com,ted.meng@l-e-i.com'

    sql = "
        with
          tekpo as
            (select /*+ materialize*/  a.ebeln,a.ebelp from sapsr3.ekpo a
               where a.mandt='168' and a.loekz=' ' and elikz=' ' and bstae='0001'),
          teket as
            (select /*+ index (b \"EKET~0\") materialize*/ b.ebeln,b.ebelp, sum (b.menge - b.wemng) menge
               from tekpo a, sapsr3.eket b
               where b.mandt='168' and b.ebeln=a.ebeln and b.ebelp=a.ebelp
               group by b.ebeln,b.ebelp),
          tekes as
            (select /*+ index (b \"EKES~0\") materialize*/
                    b.ebeln,b.ebelp,  sum (b.menge - b.dabmg) menge
               from tekpo a, sapsr3.ekes b
               where b.mandt='168' and b.ebeln=a.ebeln and b.ebelp=a.ebelp
               group by b.ebeln,b.ebelp)
          select a.ebeln,a.ebelp,b.menge eket,c.menge ekes,d.bsart
            from tekpo a, teket b,tekes c, sapsr3.ekko d
            where b.ebeln=a.ebeln and b.ebelp=a.ebelp
              and c.ebeln=a.ebeln and c.ebelp=a.ebelp
              and c.menge>b.menge
              and b.menge>0
              and d.mandt='168' and d.ebeln=a.ebeln and d.bsart not in ('Z006','Z008')
    "
    rows = Sapdb.find_by_sql(sql)
    if rows.present?
      subject = "SAP 確認(EKES)數量異常 - #{rows.count} 筆, 請修正"
      excel = Excel.resultset(rows)
      filename = "log/#{SecureRandom.hex}.xlsx"
      excel.serialize(filename)
      Mail.deliver do
        from from
        to to
        subject subject
        body 'warehouse::app::models::report::ekes_check'
        add_file filename: filename
      end
      File.delete(filename)
    end
  end
end