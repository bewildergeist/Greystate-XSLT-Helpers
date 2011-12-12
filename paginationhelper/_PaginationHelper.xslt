<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet [
	<!-- Define RequestQueryString function (this one's from Umbraco) -->
	<!ENTITY queryString "umb:RequestQueryString">
	
	<!-- Paging constants -->
	<!ENTITY prevPage "&#8249; Previous">
	<!ENTITY nextPage "Next &#8250;">
	<!ENTITY pageLinks "5"> <!-- Number of pagination links to show before and after the current page -->

	<!ENTITY searchParam "q"> <!-- Name of QueryString parameter for 'searchTerm' -->
	<!ENTITY pagerParam "p"> <!-- Name of QueryString parameter for 'page' -->
	<!ENTITY perPage "10"> <!-- Number of items on a page -->
]>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umb="urn:umbraco.library"
	exclude-result-prefixes="umb"
>

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

	<!-- Paging variables -->
	<xsl:variable name="searchTerm" select="&queryString;('&searchParam;')"/>
	<xsl:variable name="perPage" select="&perPage;" />
	<xsl:variable name="reqPage" select="&queryString;('&pagerParam;')" />
	<xsl:variable name="page">
		<xsl:choose>
			<xsl:when test="number($reqPage) = $reqPage">
				<xsl:value-of select="$reqPage" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="1" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template name="PaginateSelection">
		<!-- The stuff to paginate - defaults to all children of the context node when invoking this -->
		<xsl:param name="selection" select="*" />

		<!-- This is to allow forcing a specific page without using QueryString -->
		<xsl:param name="page" select="$page" />

		<!-- Only show the pagination controls if there are more than one page of results -->
		<!-- You can disable the "Pager" control by setting this to false() - then manually calling RenderPager somewhere else -->
		<xsl:param name="showPager" select="boolean($perPage &lt; count($selection))" />
		
		<xsl:variable name="startIndex" select="$perPage * ($page - 1) + 1" /><!-- First item on this page -->
		<xsl:variable name="endIndex" select="$page * $perPage" /><!-- First item on next page -->
		
		<!-- Render the current page using apply-templates -->
		<xsl:apply-templates select="$selection[position() &gt;= $startIndex and position() &lt;= $endIndex]" />
		
		<!-- Should we render the pager controls? -->
		<xsl:if test="$showPager">
			<xsl:call-template name="RenderPager">
				<xsl:with-param name="selection" select="$selection" />
				<xsl:with-param name="page" select="$page" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="RenderPager">
		<xsl:param name="selection" select="*" />
		<xsl:param name="page" select="$page" />
		
		<xsl:variable name="total" select="count($selection)" />
		<xsl:variable name="lastPageNum" select="ceiling($total div $perPage)" />

		<ul class="pager">
			<!-- Create the "Previous" link (if there is a previous page) -->
			<xsl:if test="$page &gt; 1">
				<xsl:call-template name="PaginationLink">
					<xsl:with-param name="class" select="'prev'" />
					<xsl:with-param name="destination" select="$page - 1" />
					<xsl:with-param name="text" select="'&prevPage;'" />
				</xsl:call-template>
			</xsl:if>
			<!-- Create links for to the previous and next X number of pages (defined in the pageLinks entity) -->
			<xsl:for-each select="$selection[position() &lt;= $lastPageNum]">
				<xsl:choose>
					<xsl:when test="$page = position()">
						<li class="current"><xsl:value-of select="position()" /></li>
					</xsl:when>
					<xsl:when test="position() - $page &lt;= &pageLinks; and position() - $page &gt;= -&pageLinks;">
						<xsl:call-template name="PaginationLink">
							<xsl:with-param name="destination" select="position()" />
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<!-- Create the "Next" link (if there is a next page) -->
			<xsl:if test="$page &lt; $lastPageNum">
				<xsl:call-template name="PaginationLink">
					<xsl:with-param name="class" select="'next'" />
					<xsl:with-param name="destination" select="$page + 1" />
					<xsl:with-param name="text" select="'&nextPage;'" />
				</xsl:call-template>
			</xsl:if>
		</ul>
	</xsl:template>

	<xsl:template name="PaginationLink">
		<xsl:param name="class" select="false()" />
		<xsl:param name="destination" select="$page" />
		<xsl:param name="text" select="$destination" />

		<li>
			<xsl:if test="normalize-space($class)">
				<xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
			</xsl:if>
			<a>
				<xsl:attribute name="href">
					<xsl:text>?</xsl:text>
					<xsl:if test="normalize-space($searchTerm)">
						<xsl:value-of select="concat('&searchParam;', '=', $searchTerm, '&amp;')"/>
					</xsl:if>
					<xsl:value-of select="concat('&pagerParam;', '=', $destination)"/>
				</xsl:attribute>
				<xsl:value-of select="$text"/>
			</a>
		</li>
	</xsl:template>

</xsl:stylesheet>
