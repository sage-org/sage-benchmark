<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <xsl:for-each select="sparql/results/result">
                <xsl:for-each select="binding">
                    <xsl:value-of select="uri"/>
                    <xsl:value-of select="literal"/>
                    <xsl:value-of select="bnode"/>
                </xsl:for-each>
                <xsl:text>
</xsl:text>
        </xsl:for-each>
        <xsl:value-of select="sparql/boolean"/>
    </xsl:template>
</xsl:stylesheet>