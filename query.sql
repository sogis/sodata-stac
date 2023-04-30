WITH foo AS 
(
    SELECT 
        'Catalog' AS "type",
        'ch.so.geo.stac' AS id, 
        '1.0.0' AS stac_version,
        'Geodaten Kanton Solothurn' AS description
)

SELECT 
    row_to_json(foo)
FROM 
    foo;

    
    