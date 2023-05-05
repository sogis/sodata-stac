WITH bbox_obj AS 
(
    SELECT 
        jsonb_build_array(
            ST_XMin(extent),
            ST_YMin(extent),
            ST_XMax(extent),
            ST_YMax(extent)
        ) AS bbox       
    FROM 
    (
        SELECT 
            ST_Extent(ST_Transform(ST_GeomFromText(ageometry, 2056), 4326)) AS extent
        FROM 
            agi_stac_v1.item
        WHERE 
            identifier = :id
    ) AS foo
)
,
main_obj AS 
(
    SELECT 
        row_to_json(r) AS main
    FROM 
    (
        SELECT 
            'Feature' AS "type",
            '1.0.0' AS stac_version,
            :id AS id,
            jsonb_build_object(
                'datetime',
                to_char(adate AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')                
            ) AS properties,
            --ST_AsGeoJSON(ST_Transform(ST_GeomFromText(ageometry, 2056), 4326))::json AS geometry,
            bbox_obj.bbox AS bbox,
            :collectionId AS collection
        FROM 
            agi_stac_v1.item,
            bbox_obj
        WHERE 
            identifier = :id
    ) AS r
)
SELECT 
    *
FROM 
    main_obj
;
