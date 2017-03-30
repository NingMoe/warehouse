class MesTErpMoPoint

  def self.check_dup_point(aufnrs)
    points= {}
    dup_points = {}
    dup_rows = {}
    rows = MesTErpAccount.find_by_sql([mo_sql, aufnrs])

    rows.each do |row|
      if row.point.present?
        #check duplicate record on same parent and posnr diff
        dup_key = "#{row.project_no}.#{row.work_center}.#{row.wip}.#{row.item_code}.#{row.point.split(',').sort.join(',')}"
        if not dup_rows.has_key?(dup_key)
          dup_rows[dup_key] = nil
          row.point.split(',').each do |point|
            if point.present?
              key = "#{row.project_no}.#{row.work_center}.#{point}"
              datas = {point: point, project_no: row.project_no, work_center: row.work_center,
                       item_no: row.item_code, points: row.point,
                       item_plant: row.item_plant, pmatnr: row.pmatnr, item_group: row.item_group,
                       item_group_desc: row.item_group_desc, wip: row.wip, posnr: row.posnr
              }
              if points.has_key?(key)
                if dup_points.has_key?(key)
                  dup_points[key].append datas
                else
                  dup_points[key] = []
                  dup_points[key].append points[key]
                  dup_points[key].append datas
                end
              else
                points[key] = datas
              end
            end
          end
        end
      end
    end
    dup_points.keys.each do |key|
      dup_points[key].each do |row|
        #puts "#{key} #{row.item_code} #{row.point}"
        puts row
      end
    end
    dup_points
  end


  def self.mo_sql
    "
      WITH BOM_LIST AS
       (SELECT /*+ MATERIALIZE */
         A.AUFNR PROJECT_NO,
         A.MATNR ITEM_CODE,
         A.WERKS ITEM_PLANT,
         SUM(A.BDMNG) PROJECT_ITEM_NUM,
         SUM(A.ENMNG) PROJECT_ITEM_ISS,
         SUM(A.ESMNG) ITEM_NUM,
         A.MATKL ITEM_GROUP,
         B.WGBEZ ITEM_GROUP_DESC,
         D.ARBPL WORK_CENTER,
         CASE
           WHEN D.ARBPL LIKE '%RI%' THEN
            '02'
           WHEN D.ARBPL LIKE '%AI%' THEN
            '01'
           WHEN D.ARBPL LIKE '%SMT%' THEN
            '00'
           WHEN D.ARBPL LIKE '%301%' THEN
            '03'
           ELSE
            '04'
         END ITEM_RANK,
         A.BAUGR WIP,
         A.POSNR,
         E.MATNR PMATNR,
         E.PWERK PWERK,
         RTRIM(REPLACE(to_char(WM_CONCAT(A.ABLAD)), ' ', ''), ',') POINT
          FROM SAPSR3.RESB@SAPP A
          LEFT JOIN SAPSR3.T023T@SAPP B
            ON B.MANDT = A.MANDT
           AND B.SPRAS = 'M'
           AND B.MATKL = A.MATKL
          JOIN SAPSR3.AFVC@SAPP C
            ON C.MANDT = A.MANDT
           AND C.AUFPL = A.AUFPL
           AND C.APLZL = A.APLZL
        /*AND C.PLNFL = A.PLNFL*/
          LEFT JOIN SAPSR3.CRHD@SAPP D
            ON D.MANDT = C.MANDT
           AND D.OBJTY = 'A'
           AND D.OBJID = C.ARBID
           AND A.BDTER BETWEEN D.BEGDA AND D.ENDDA
          JOIN SAPSR3.AFPO@SAPP E
            ON E.MANDT = A.MANDT
           AND E.AUFNR = A.AUFNR
         WHERE A.MANDT = '168'
           AND A.DUMPS = ' '
           AND A.BDMNG <> 0
           AND A.XLOEK = ' '
           AND A.AUFNR in (?)
              /* AND A.RSPOS<'5000'*/
           AND A.potx2 <> 'MES_OVERLOAD'
         GROUP BY A.AUFNR,
                  A.MATNR,
                  A.WERKS,
                  A.MATKL,
                  B.WGBEZ,
                  D.ARBPL,
                  E.MATNR,
                  E.PWERK,
                  A.BAUGR,
                  A.POSNR,
                  CASE
                    WHEN D.ARBPL LIKE '%RI%' THEN
                     '02'
                    WHEN D.ARBPL LIKE '%AI%' THEN
                     '01'
                    WHEN D.ARBPL LIKE '%SMT%' THEN
                     '00'
                    WHEN D.ARBPL LIKE '%302%' THEN
                     '03'
                    ELSE
                     '04'
                  END),
      T AS
       (SELECT DISTINCT A.PROJECT_NO,
                        A.ITEM_CODE,
                        A.ITEM_PLANT,
                        A.PROJECT_ITEM_NUM,
                        A.PROJECT_ITEM_ISS,
                        A.ITEM_NUM,
                        A.ITEM_GROUP,
                        A.ITEM_GROUP_DESC,
                        A.WORK_CENTER,
                        A.ITEM_RANK,
                        A.PWERK,
                        A.PMATNR,
                        A.WIP,
                        A.POSNR,
                        A.POINT,
                        Z.locationinfo
          FROM BOM_LIST A
          LEFT JOIN IPQCWEB.SAP_PBOMXTB@TXDB Z
            ON Z.PMATNR = A.WIP
           AND Z.PLANT = A.PWERK
           AND Z.CMATNR = A.ITEM_CODE
           AND BLEVEL = 1)
      SELECT PROJECT_NO,
             ITEM_CODE,
             ITEM_PLANT,
             PROJECT_ITEM_NUM,
             PROJECT_ITEM_ISS,
             ITEM_NUM,
             ITEM_GROUP,
             ITEM_GROUP_DESC,
             WORK_CENTER,
             ITEM_RANK,
             PWERK,
             PMATNR,
             WIP,
             POSNR,
             NVL(REPLACE(T.POINT, ' ', ''),
                 NVL(REPLACE(TO_CHAR(WM_CONCAT(LOCATIONINFO)), ',,', ','),
                     (SELECT MAX(POINT)
                        FROM T_ERP_POINT C
                       WHERE C.PMATNR = T.WIP
                         AND C.PWERK = T.PWERK
                         AND C.ITEM_CODE = SUBSTR(T.ITEM_CODE, 1, 7) || '000' ||
                             SUBSTR(T.ITEM_CODE, 11, 1)))) POINT

        FROM T
       GROUP BY PROJECT_NO,
                ITEM_CODE,
                ITEM_PLANT,
                PROJECT_ITEM_NUM,
                PROJECT_ITEM_ISS,
                ITEM_NUM,
                ITEM_GROUP,
                ITEM_GROUP_DESC,
                WORK_CENTER,
                ITEM_RANK,
                PWERK,
                PMATNR,
                WIP,
                POSNR,
                T.POINT
   "
  end

end