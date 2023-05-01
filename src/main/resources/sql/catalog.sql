WITH links AS 
(
    SELECT 
        jsonb_strip_nulls(json_agg(c)::jsonb) AS link_array
    FROM 
    (
        SELECT 
            'root' AS rel,
            :host||'/catalog.json' AS href,
            'application/json' AS "type",
            NULL::TEXT AS title
        UNION ALL
        SELECT 
            'child' AS rel,
            :host||'/'||identifier||'/collection.json' AS href,
            'application/json' AS "type",
            title AS title
        FROM 
            agi_stac_v1.collection  
        UNION ALL
        SELECT 
            'self' AS rel,
            :host||'/catalog.json' AS href,
            'application/json' AS "type",
            NULL::TEXT AS title
    ) AS c
)
,
main_obj AS 
(
    SELECT 
        row_to_json(r) AS main
    FROM 
    (
        SELECT 
            'Catalog' AS "type",
            'ch.so.geo.stac' AS id, 
            '1.0.0' AS stac_version,
            'Geodaten Kanton Solothurn' AS description,
            links.link_array AS links
        FROM 
            links
    ) AS r
)
SELECT 
    --jsonb_pretty(main::jsonb)
    main::text
FROM 
    main_obj
;
