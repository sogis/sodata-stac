<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:myns="ch.so.agi" exclude-result-prefixes="myns" version="3.0"> 
    <xsl:output method="xml" indent="yes"/>
    

    <xsl:template match="/themePublications">
        <TRANSFER xmlns="http://www.interlis.ch/INTERLIS2.3">
        <HEADERSECTION SENDER="sodata" VERSION="2.3">
            <MODELS>
            <MODEL NAME="SO_AGI_STAC_20230426" VERSION="2023-04-26" URI="https://agi.so.ch"/>
            </MODELS>
        </HEADERSECTION>

        <DATASECTION>
            <SO_AGI_STAC_20230426.Collections BID="SO_AGI_STAC_20230426.Collections">

                <xsl:message>Hallo Delivery</xsl:message>

                <xsl:apply-templates select="themePublication" /> 

            </SO_AGI_STAC_20230426.Collections>

        </DATASECTION>
        </TRANSFER>
    </xsl:template>

    <xsl:template match="themePublication">     
        <SO_AGI_STAC_20230426.Collections.Collection xmlns="http://www.interlis.ch/INTERLIS2.3" TID="{identifier}">
            <Identifier xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="identifier"/>
            </Identifier>
            <Title xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="title"/>
            </Title>
            <ShortDescription xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="shortDescription"/>
            </ShortDescription>
            <SpatialExtent xmlns="http://www.interlis.ch/INTERLIS2.3">
                <SO_AGI_STAC_20230426.Collections.BoundingBox xmlns="http://www.interlis.ch/INTERLIS2.3">
                    <westlimit xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="bbox/left"/></westlimit>
                    <southlimit xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="bbox/bottom"/></southlimit>
                    <eastlimit xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="bbox/right"/></eastlimit>
                    <northlimit xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="bbox/top"/></northlimit>
                </SO_AGI_STAC_20230426.Collections.BoundingBox>
            </SpatialExtent>
            <TemporalExtent xmlns="http://www.interlis.ch/INTERLIS2.3">
                <SO_AGI_STAC_20230426.Collections.Interval xmlns="http://www.interlis.ch/INTERLIS2.3">
                    <xsl:if test="secondToLastPublishingDate" >
                        <StartDate xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="secondToLastPublishingDate"/></StartDate>
                    </xsl:if>
                    <EndDate xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="lastPublishingDate"/></EndDate>
                </SO_AGI_STAC_20230426.Collections.Interval>
            </TemporalExtent>
            <Licence xmlns="http://www.interlis.ch/INTERLIS2.3">https://files.geo.so.ch/nutzungsbedingungen.html</Licence>

            <xsl:if test="keywords">
                <Keywords xmlns="http://www.interlis.ch/INTERLIS2.3">
                    <xsl:for-each select="keywords/keyword">
                        <SO_AGI_STAC_20230426.Collections.Keyword_ xmlns="http://www.interlis.ch/INTERLIS2.3">
                            <Keyword xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="."/></Keyword>
                        </SO_AGI_STAC_20230426.Collections.Keyword_>
                    </xsl:for-each>
                </Keywords>
            </xsl:if>

            <Items xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:variable name="itemsNo" select="count(items/item)"/>
                
                <xsl:for-each select="items/item">
                    <xsl:variable name="itemIdentifier" select="identifier"/>
                    
                    <SO_AGI_STAC_20230426.Collections.Item xmlns="http://www.interlis.ch/INTERLIS2.3">
                        <Identifier xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="identifier"/></Identifier>
                        <Date xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="lastPublishingDate"/></Date>
                        <Boundary xmlns="http://www.interlis.ch/INTERLIS2.3">
                            <SO_AGI_STAC_20230426.Collections.BoundingBox xmlns="http://www.interlis.ch/INTERLIS2.3">
                                <westlimit xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="bbox/left"/></westlimit>
                                <southlimit xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="bbox/bottom"/></southlimit>
                                <eastlimit xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="bbox/right"/></eastlimit>
                                <northlimit xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="bbox/top"/></northlimit>
                            </SO_AGI_STAC_20230426.Collections.BoundingBox>
                        </Boundary>
                        <Geometry xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="geometry"/></Geometry>
                        <Assets xmlns="http://www.interlis.ch/INTERLIS2.3">


                            <xsl:for-each select="../../fileFormats/fileFormat">
                                <xsl:variable name="assetIdentifierTmp" select="concat(../../identifier, '.', abbreviation)"/>
                                <xsl:variable name="assetIdentifier">
                                    <xsl:choose>
                                        <xsl:when test="$itemsNo > 1">
                                            <xsl:value-of select="concat($itemIdentifier, '.', ../../identifier, '.', abbreviation)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$assetIdentifierTmp" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                    <SO_AGI_STAC_20230426.Collections.Asset xmlns="http://www.interlis.ch/INTERLIS2.3">
                                        <Identifier xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="$assetIdentifier"/></Identifier>
                                        <Title xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="concat($itemIdentifier, ' (', abbreviation, ')')"/></Title>
                                        <MediaType xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="mimetype"/></MediaType>
                                        <Href xmlns="http://www.interlis.ch/INTERLIS2.3"><xsl:value-of select="concat(../../downloadHostUrl, '/', ../../identifier, '/aktuell/', $assetIdentifier)"/></Href>
                                    </SO_AGI_STAC_20230426.Collections.Asset>
                            </xsl:for-each>
                        </Assets>
                    </SO_AGI_STAC_20230426.Collections.Item>
                </xsl:for-each>
            </Items>

        </SO_AGI_STAC_20230426.Collections.Collection>

    </xsl:template>

<!--
    <xsl:template match="eCH-0132:newInsuranceValue | eCH-0132:cancellation">
        <xsl:message>Hallo newInsuranceValue or cancellation</xsl:message>

        <SO_AGI_SGV_Meldungen_20221109.Meldungen.Meldung xmlns="http://www.interlis.ch/INTERLIS2.3" TID="1">
            <xsl:if test="eCH-0132:buildingInformation[1]/eCH-0132:building[1]/eCH-0129:coordinates">
                <Lage xmlns="http://www.interlis.ch/INTERLIS2.3">
                    <COORD xmlns="http://www.interlis.ch/INTERLIS2.3">
                        <C1 xmlns="http://www.interlis.ch/INTERLIS2.3">
                            <xsl:value-of select="eCH-0132:buildingInformation[1]/eCH-0132:building[1]/eCH-0129:coordinates/eCH-0129:east" />
                        </C1>
                        <C2 xmlns="http://www.interlis.ch/INTERLIS2.3">
                            <xsl:value-of select="eCH-0132:buildingInformation[1]/eCH-0132:building[1]/eCH-0129:coordinates/eCH-0129:north" />                        
                        </C2>
                    </COORD>
                </Lage>
            </xsl:if>

            <Grundstuecksnummer xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="number(tokenize(eCH-0132:buildingInformation[1]/eCH-0132:realestate[1]/eCH-0129:realestateIdentification/eCH-0129:number, '-')[last()])" />
            </Grundstuecksnummer>

            <EGRID xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="eCH-0132:buildingInformation[1]/eCH-0132:realestate[1]/eCH-0129:realestateIdentification/eCH-0129:EGRID" />
            </EGRID>

            <NBIdent xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="eCH-0132:buildingInformation[1]/eCH-0132:realestate[1]/eCH-0129:namedMetaData/eCH-0129:metaDataName[text() = 'NBIdent']/following-sibling::eCH-0129:metaDataValue" />
            </NBIdent>

            <Datum_Meldung xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
            </Datum_Meldung>

            <Meldegrund xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="key('myns:lookup-eventType', eCH-0132:event, $myns:eventType-lookup)/@value"/>
            </Meldegrund>

            <Baujahr xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="eCH-0132:buildingInformation[1]/eCH-0132:building[1]/eCH-0129:dateOfConstruction/eCH-0129:year" />
            </Baujahr>

            <Gebaeudebezeichnung xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="key('myns:lookup-eventType', eCH-0132:buildingInformation[1]/eCH-0132:building[1]/eCH-0129:buildingCategory, $myns:buildingCategoryType-lookup)/@value"/>
            </Gebaeudebezeichnung>

            <Gebaeudeadresse xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="eCH-0132:buildingInformation[1]/eCH-0132:buildingEntranceInformation[1]/eCH-0132:localisationInformation/eCH-0132:street/eCH-0129:description/eCH-0129:descriptionLong" />
                <xsl:text>&#x20;</xsl:text>
                <xsl:value-of select="eCH-0132:buildingInformation[1]/eCH-0132:buildingEntranceInformation[1]/eCH-0132:buildingEntrance/eCH-0129:buildingEntranceNo" />
                <xsl:text>,&#x20;</xsl:text>
                <xsl:value-of select="eCH-0132:buildingInformation[1]/eCH-0132:buildingEntranceInformation[1]/eCH-0132:localisationInformation/eCH-0132:locality/eCH-0129:swissZipCode" />
                <xsl:text>&#x20;</xsl:text>
                <xsl:value-of select="eCH-0132:buildingInformation[1]/eCH-0132:buildingEntranceInformation[1]/eCH-0132:localisationInformation/eCH-0132:locality/eCH-0129:name/eCH-0129:nameLong" />
            </Gebaeudeadresse>

            <Versicherungsbeginn xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="eCH-0132:insuranceValue/eCH-0129:validFrom" />
            </Versicherungsbeginn>

            <Verwalter xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:call-template name="custodianOrPolicyholder">
                    <xsl:with-param name="address" select="eCH-0132:custodian/eCH-0132:mailAddress" />
                </xsl:call-template>
            </Verwalter>

            <Eigentuemer xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:choose>
                    <xsl:when test="eCH-0132:policyholder/eCH-0132:mailAddress">
                        <xsl:for-each select="eCH-0132:policyholder/eCH-0132:mailAddress">
                            <xsl:call-template name="custodianOrPolicyholder">
                                <xsl:with-param name="address" select="." />
                            </xsl:call-template>
                            <xsl:if test="position() != last()">
                                <xsl:text>&#x20;/&#x20;</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>DUMMY</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </Eigentuemer>

            <Baulicher_Mehrwert xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="eCH-0132:buildingInformation[1]/eCH-0132:building[1]/eCH-0129:namedMetaData/eCH-0129:metaDataName[text() = 'benefit']/following-sibling::eCH-0129:metaDataValue" />
            </Baulicher_Mehrwert>

            <Status xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:text>neu</xsl:text>
            </Status>

            <MessageId xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="/eCH-0132:delivery/eCH-0132:deliveryHeader/eCH-0058:messageId" />
            </MessageId>

            <InsuranceObjectId xmlns="http://www.interlis.ch/INTERLIS2.3">
                <xsl:value-of select="eCH-0132:insuranceObject/eCH-0129:insuranceNumber" />
            </InsuranceObjectId>

        </SO_AGI_SGV_Meldungen_20221109.Meldungen.Meldung>
    </xsl:template>
-->
<!--
    <xsl:template name="custodianOrPolicyholder">
        <xsl:param name="address" />
        <xsl:choose>
            <xsl:when test="$address/eCH-0010:organisation">
                <xsl:value-of select="$address/eCH-0010:organisation/eCH-0010:organisationName" />
                <xsl:text>,&#x20;</xsl:text>
            </xsl:when>
            <xsl:when test="$address/eCH-0010:person">
                <xsl:value-of select="$address/eCH-0010:person/eCH-0010:firstName" />
                <xsl:text>&#x20;</xsl:text>
                <xsl:value-of select="$address/eCH-0010:person/eCH-0010:lastName" />
                <xsl:text>,&#x20;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>DUMMY</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$address/eCH-0010:addressInformation/eCH-0010:street" />
        <xsl:text>&#x20;</xsl:text>
        <xsl:value-of select="$address/eCH-0010:addressInformation/eCH-0010:houseNumber" />
        <xsl:text>,&#x20;</xsl:text>
        <xsl:value-of select="$address/eCH-0010:addressInformation/eCH-0010:swissZipCode" />
        <xsl:text>&#x20;</xsl:text>
        <xsl:value-of select="$address/eCH-0010:addressInformation/eCH-0010:town" />
    </xsl:template>
-->

</xsl:stylesheet>