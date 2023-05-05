
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
assets_obj AS 
(
    SELECT 
        jsonb_object_agg(mykey, myvalue) AS assets
    FROM 
    (
        SELECT 
            assets->>'Identifier' AS mykey,
            jsonb_build_object(
                'href',
                assets->>'Href',
                'type',
                assets->>'MediaType',
                'title',
                assets->>'Title'
            ) AS myvalue
        FROM 
        (
            -- Ili2db bildet das leider so ab, dass ein einzelnes
            -- Object nicht ein Toplevel-Array erhält, sondern
            -- ein einzelnes Objekt bleibt. Aus diesem Grund müssen
            -- wir aus dem Objekt ein Json-Array machen.
            SELECT 
                jsonb_array_elements(asset) AS assets
            FROM 
            (
                SELECT 
                    CASE 
                        WHEN jsonb_typeof(assets) = 'array' THEN assets
                        ELSE jsonb_build_array(assets)
                    END AS asset
                FROM 
                    agi_stac_v1.item 
                WHERE 
                    identifier = :id
            ) AS asset_array
        ) AS objects
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
            assets_obj.assets AS assets,
            bbox_obj.bbox AS bbox,
            :collectionId AS collection
        FROM 
            agi_stac_v1.item,
            assets_obj,
            bbox_obj
        WHERE 
            identifier = :id
    ) AS r
)
SELECT 
    --jsonb_pretty(main::jsonb)
    main::text
FROM 
    main_obj
;

