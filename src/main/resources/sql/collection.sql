/*
 * (1) Extent Queries funktionieren nur solange es nur jeweils ein (1) Interval oder eine Bbox in den 
 * Ausgangsdaten gibt. Möglich sind mehrere. 
 */
WITH items AS (
    SELECT 
        item.*,
        collection.identifier AS collection_identifier
    FROM 
        :dbSchema.item AS item 
        LEFT JOIN :dbSchema.collection AS collection
        ON collection.t_id = item.collection_items
    WHERE 
        collection.identifier = :id          
)
,
links_array AS 
(
    SELECT 
        jsonb_strip_nulls(jsonb_agg(c)) AS links
    FROM 
    (
        SELECT 
            'root' AS rel,
            :host||'/catalog.json' AS href,
            'application/json' AS "type",
            NULL::TEXT AS title
        UNION ALL
        SELECT 
            'parent' AS rel,
            :host||'/catalog.json' AS href,
            'application/json' AS "type",
            NULL::TEXT AS title
        UNION ALL
        SELECT 
            'item' AS rel,
            :host||'/'||collection_identifier||'/'||identifier||'/'||identifier||'.json' AS href,
            'application/json' AS "type",
            items.title AS title
        FROM 
            items
        UNION ALL
        SELECT
            'self' AS rel,
            :host||'/'||identifier||'/collection.json' AS href,
            'application/json' AS "type",
            title AS title
        FROM 
            :dbSchema.collection  
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
                    -- Runden weil Output nicht auf jedem OS gleich.
                    round(ST_X(lowerleft)::numeric, 12),
                    round(ST_Y(lowerleft)::numeric, 12),
                    round(ST_X(upperright)::numeric, 12),
                    round(ST_Y(upperright)::numeric, 12)
                )        
            )        
        ) AS spatialextent 
    FROM 
    (
        SELECT 
            ST_Transform(ST_SetSrid(ST_MakePoint((spatialextent->>'westlimit')::float, (spatialextent->>'southlimit')::float), 2056), 4326) AS lowerleft,
            ST_Transform(ST_SetSrid(ST_MakePoint((spatialextent->>'eastlimit')::float, (spatialextent->>'northlimit')::float), 2056), 4326) AS upperright
        FROM 
            :dbSchema.collection
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
        :dbSchema.collection
    WHERE 
        identifier = :id
)
,
keywords_array AS 
(
    SELECT 
        jsonb_agg(
            keywords->>'Keyword'
        ) AS keywords
    FROM    
    (
        SELECT 
            jsonb_array_elements(keyword) AS keywords
        FROM 
        (
            -- Siehe assets bei den items (ist wegen ili2db)
            SELECT 
                CASE 
                    WHEN jsonb_typeof(keywords) = 'array' THEN keywords
                    ELSE jsonb_build_array(keywords)
                END AS keyword
            FROM 
                :dbSchema.collection 
            WHERE
                keywords IS NOT NULL
            AND 
                identifier = :id
        ) AS foo    
    ) AS bar
)
,
providers_array AS 
(
    SELECT 
        jsonb_agg(provider) AS providers
    FROM 
    (
        SELECT 
            jsonb_build_object(
                'name',
                aowner->>'AgencyName',
                'roles',
                jsonb_build_array('processor'),
                'url',
                aowner->>'OfficeAtWeb'
            ) AS provider
        FROM 
            :dbSchema.collection
        WHERE 
            identifier = :id    
        UNION ALL 
        SELECT 
            jsonb_build_object(
                'name',
                servicer->>'AgencyName',
                'roles',
                jsonb_build_array('host'),
                'url',
                servicer->>'OfficeAtWeb'
            ) AS provider
        FROM 
            :dbSchema.collection
        WHERE 
            identifier = :id    
    ) AS providers
)
,
main_obj AS 
(
    SELECT 
        json_strip_nulls(row_to_json(r))::jsonb AS main
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
            links_array.links,
            keywords_array.keywords AS keywords,
            providers_array.providers AS providers,
            jsonb_build_object(
                'proj:epsg',
                '2056',
                'proj:name',
                'CH1903+ / LV95'
            ) AS summaries
        FROM 
            :dbSchema.collection,
            spatialextent_obj,
            temporalextent_obj,
            links_array,
            keywords_array,
            providers_array
        WHERE 
            identifier = :id
    ) AS r
)
SELECT 
    --jsonb_pretty(main::jsonb)
    main::text
    --main
FROM 
    main_obj
;
