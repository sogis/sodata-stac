/*
 * (1) Extent Queries funktionieren nur solange es nur jeweils ein (1) Interval oder eine Bbox in den 
 * Ausgangsdaten gibt. Möglich sind mehrere. 
 */
WITH items AS (
    SELECT 
        item.*,
        collection.identifier AS collection_identifier
    FROM 
        agi_stac_v1.item AS item 
        LEFT JOIN agi_stac_v1.collection AS collection
        ON collection.t_id = item.collection_items
    WHERE 
        collection.identifier = :id          
)
,
links_array AS 
(
    SELECT 
        jsonb_strip_nulls(json_agg(c)::jsonb) AS links
    FROM 
    (
        SELECT 
            'root' AS rel,
            'http://localhost:8080'||'/catalog.json' AS href,
            'application/json' AS "type",
            NULL::TEXT AS title
        UNION ALL
        SELECT 
            'parent' AS rel,
            'http://localhost:8080'||'/catalog.json' AS href,
            'application/json' AS "type",
            NULL::TEXT AS title
        UNION ALL
        SELECT 
            --items.*
            'child' AS rel,
            :host||'/'||collection_identifier||'/'||identifier||'/'||identifier||'.json' AS href,
            'application/json' AS "type",
            NULL::TEXT AS title
        FROM 
            items
        UNION ALL
        SELECT
            'self' AS rel,
            :host||'/'||identifier||'/collection.json' AS href,
            'application/json' AS "type",
            title AS title
        FROM 
            agi_stac_v1.collection  
        WHERE 
            identifier = :id
    ) AS c
)

,
spatialextent_obj AS 
(
    SELECT 
        jsonb_build_object(
            'bbox',
            jsonb_build_array(
                jsonb_build_array(
                    ST_X(lowerleft),
                    ST_Y(lowerleft),
                    ST_X(upperright),
                    ST_Y(upperright)
                )        
            )        
        ) AS spatialextent 
    FROM 
    (
        SELECT 
            ST_Transform(ST_SetSrid(ST_MakePoint((spatialextent->>'westlimit')::float, (spatialextent->>'southlimit')::float), 2056), 4326) AS lowerleft,
            ST_Transform(ST_SetSrid(ST_MakePoint((spatialextent->>'eastlimit')::float, (spatialextent->>'northlimit')::float), 2056), 4326) AS upperright
        FROM 
            agi_stac_v1.collection
        WHERE 
            identifier = :id
    ) AS foo
)
,
temporalextent_obj AS 
(
    SELECT
        jsonb_build_object(
            'interval',
            jsonb_build_array(
                jsonb_build_array(
                    to_char(date(temporalextent->>'StartDate') AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
                    to_char(date(temporalextent->>'EndDate') AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                )
            )
        ) AS temporalextent
    FROM 
        agi_stac_v1.collection
    WHERE 
        identifier = :id
)
,
main_obj AS 
(
    SELECT 
        row_to_json(r) AS main
    FROM 
    (
        SELECT 
            'Collection' AS "type",
            identifier AS id, 
            '1.0.0' AS stac_version,
            title AS title,
            shortdescription AS description,
            licence AS licence,
                json_build_object(
                    'spatial',
                    spatialextent_obj.spatialextent,
                    'temporal',
                    temporalextent_obj.temporalextent
                ) AS extent,
            links_array.links
        FROM 
            agi_stac_v1.collection,
            spatialextent_obj,
            temporalextent_obj,
            links_array
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
