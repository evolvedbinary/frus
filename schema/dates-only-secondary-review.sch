<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:functx="http://www.functx.com"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:historyatstate="https://history.state.gov/historyatstate">
    <title>FRUS TEI Rules - Date Rules</title>

    <p>This schematron file contains date-related rules from and augmenting frus.sch. This current
        version is geared towards secondary-review of legacy volumes.</p>

    <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <ns prefix="frus" uri="http://history.state.gov/frus/ns/1.0"/>
    <ns prefix="xml" uri="http://www.w3.org/XML/1998/namespace"/>
    <ns prefix="xi" uri="http://www.w3.org/2001/XInclude"/>
    <ns prefix="fn" uri="http://www.w3.org/2005/xpath-functions"/>
    <ns prefix="functx" uri="http://www.functx.com"/>
    <ns prefix="historyatstate" uri="https://history.state.gov/historyatstate"/>

    <let name="category-ids" value="//tei:category/@xml:id"/>

    <pattern id="pointer-checks">
        <title>Ref and Pointer Checks</title>
        <rule context="tei:date[@ana]">
            <assert test="substring-after(@ana, '#') = $category-ids">date/@ana='<value-of
                    select="@ana"/>' is an invalid value. No category has been defined with an
                @xml:id corresponding to this value.</assert>
        </rule>
        <rule context="tei:date[@type]">
            <assert role="warn"
                test="./@type = ('content-date', 'conversation-or-meeting-date', 'creation-date', 'publication-date', 'received-date')"
                    >date/@type='<value-of select="@type"/>' is an invalid value. Only the following
                values are allowed: conversation-or-meeting-date, content-date, creation-date,
                received-date</assert>
        </rule>
        <rule context="tei:date[@calendar]">
            <assert role="warn"
                test="tokenize(./@calendar) = ('chinese-era', 'chinese-lunar', 'ethiopian-ge&#8217;ez', 'gregorian', 'haitian-era', 'hijri', 'iranian-persian', 'japanese-nengō', 'julian', 'korean-era', 'korean-lunar', 'masonic-anno-lucis', 'rumi', 'thai-era', 'tibetan-phugpa')"
                    >date/@calendar='<value-of select="@type"/>' is an invalid value. Only the
                following values are allowed: chinese-era, chinese-lunar, ethiopian-ge&#8217;ez,
                gregorian, haitian-era, hijri, iranian-persian, japanese-nengō, julian, korean-era,
                korean-lunar, masonic-anno-lucis, rumi, thai-era, tibetan-phugpa. If you need to add
                additional calendar value(s), please add to frus.sch, dates-only.sch, and
                dates-only-initial-review.sch</assert>
        </rule>
    </pattern>

    <pattern id="dateline-date-checks">
        <title>Dateline Date Checks</title>
        <rule
            context="tei:dateline[not(ancestor::frus:attachment)][matches(., 'undated|not\s+dated|not\s+declassified', 'i')]">
            <assert test="exists(.//tei:date)">Please tag "undated" phrase in this document dateline
                with a &lt;date&gt; element.</assert>
        </rule>
        <rule
            context="tei:dateline[ancestor::frus:attachment][matches(., 'undated|not\s+dated|not\s+declassified', 'i')]">
            <assert role="warn" test="exists(.//tei:date)">Please tag "undated" phrase in this
                attachment dateline with a &lt;date&gt; element.</assert>
        </rule>
        <!--
        <rule context="tei:dateline[not(ancestor::frus:attachment)]">
            <assert test=".//tei:date">Document datelines must contain a date element</assert>
        </rule>
        -->
        <rule
            context="tei:dateline[not(ancestor::frus:attachment)][ancestor::tei:div[attribute::subtype eq 'historical-document'][not(descendant::tei:dateline[not(ancestor::frus:attachment)]//tei:date)]]">
            <assert test=".//tei:date">Within historical documents, at least one dateline must
                contain a date element</assert>
        </rule>
        <!--
        <rule context="tei:dateline[ancestor::frus:attachment]">
            <assert role="warn" test=".//tei:date">Attachment datelines should contain a date
                element if this information is present</assert>
        </rule>
        -->
        <rule
            context="tei:dateline[ancestor::frus:attachment[not(descendant::tei:dateline//tei:date)]]">
            <assert role="warn" test=".//tei:date">Within attachments, at least one dateline must
                contain a date element</assert>
        </rule>
        <!-- Tentative rule -->
        <!-- <rule
            context="tei:date[ancestor::tei:dateline and not(ancestor::frus:attachment)][matches(., 'undated|not\s+dated|not\s+declassified', 'i')]"> -->
        <rule
            context="tei:date[ancestor::tei:dateline][matches(., 'undated|not\s+dated|not\s+declassified', 'i')]">
            <assert
                test="(@notBefore and @notAfter and @ana) or (@when and @ana) or (@from and @to and @ana)"
                >Undated documents must be tagged with @when/@ana --OR-- @from/@to/@ana --OR--
                @notBefore/@notAfter/@ana. &#10; Use @when/@ana for a single date/dateTime that can
                be inferred concretely (such as a date listed in the original document). &#10; Use
                @from/@to/@ana for a date/dateTime range that can be inferred concretely (such as a
                meeting day and time span). &#10; Use @notBefore/@notAfter/@ana for an inferred,
                fuzzy dateTime range (such as an unknown date/time between two documents or
                events).</assert>
        </rule>
        <!-- <rule
            context="tei:date[ancestor::tei:dateline and not(ancestor::frus:attachment)][. ne '' and not(matches(., 'undated|not\s+dated|not\s+declassified', 'i'))]"> -->
        <rule
            context="tei:date[ancestor::tei:dateline][. ne '' and not(matches(., 'undated|not\s+dated|not\s+declassified', 'i'))]">
            <assert
                test="@when or (@from and @to) or (@notBefore and @notAfter and @ana) or (@when and @notBefore and @notAfter and @ana)"
                >Supplied dates must have @when (for single dates) or @from/@to (for supplied date
                ranges) or @notBefore/@notAfter/@ana/(/@when) (for imprecise year or year-month only
                dates)</assert>
        </rule>
        <rule context="tei:date[ancestor::tei:dateline and not(ancestor::frus:attachment)]">
            <assert role="warn" test="normalize-space(.) ne ''">Dateline date should not be
                empty.</assert>
            <assert test="(@from and @to) or (not(@from) and not(@to))">Dateline date @from must
                have a corresponding @to.</assert>
            <assert test="(@notBefore and @notAfter) or (not(@notBefore) and not(@notAfter))"
                >Dateline date @notBefore must have a corresponding @notAfter.</assert>
            <assert role="warn"
                test="(@notBefore and @notAfter and @ana) or (not(@notBefore) and not(@notAfter))"
                >Missing @ana explaining the analysis used to determine @notBefore and
                @notAfter.</assert>
            <assert
                test="
                    every $date in @when
                        satisfies ((matches($date, '^\d{4}$') and ($date || '-01-01') castable as xs:date) or (matches($date, '^\d{4}-\d{2}$') and ($date || '-01') castable as xs:date) or $date castable as xs:date or $date castable as xs:dateTime)"
                >Dateline date @when values must be YYYY, YYYY-MM, or xs:date or
                xs:dateTime</assert>
            <assert
                test="
                    every $date in (@from, @to, @notBefore, @notAfter)
                        satisfies ($date castable as xs:date or $date castable as xs:dateTime)"
                >Dateline date @from/@to/@notBefore/@notAfter must be valid xs:date or xs:dateTime
                values.</assert>
            <assert
                test="
                    every $attribute in @*
                        satisfies not(matches($attribute, '[A-Z]$'))"
                >Please use timezone offset instead of military time zone (e.g., replace Z with
                +00:00).</assert>
            <assert
                test="
                    if (@from and @to) then
                        (@from le @to)
                    else
                        true()"
                >Dateline date @from must come before @to.</assert>
            <assert
                test="
                    if (@notBefore and @notAfter) then
                        (@notBefore le @notAfter)
                    else
                        true()"
                >Dateline date @notBefore must come before @notAfter.</assert>
        </rule>
    </pattern>

    <pattern id="document-date-metadata-checks">
        <title>Document Date Metadata Checks</title>
        <rule
            context="tei:div[@type eq 'document'][not(@subtype = ('editorial-note', 'errata_document-numbering-error', 'index'))][not(.//tei:dateline[not(ancestor::frus:attachment)]//tei:date[@from or @to or @notBefore or @notAfter or @when])]">
            <assert test=".//tei:dateline[not(ancestor::frus:attachment)]"
                sqf:fix="add-dateline-date-only add-full-dateline">Non-editorial note documents must
                have a dateline with date metadata.</assert>
            <sqf:fix id="add-dateline-date-only">
                <sqf:description>
                    <sqf:title>Add dateline with empty date</sqf:title>
                </sqf:description>
                <sqf:add use-when="not(tei:opener)" match="tei:head[1]" position="after">
                    <dateline xmlns="http://www.tei-c.org/ns/1.0">
                        <date/>
                    </dateline>
                </sqf:add>
                <sqf:add use-when="tei:opener" match="tei:opener[1]" position="last-child">
                    <dateline xmlns="http://www.tei-c.org/ns/1.0">
                        <date/>
                    </dateline>
                </sqf:add>
            </sqf:fix>
            <sqf:fix id="add-full-dateline">
                <sqf:description>
                    <sqf:title>Add dateline with empty placeName and date</sqf:title>
                </sqf:description>
                <sqf:add use-when="not(tei:opener)" match="tei:head[1]" position="after">
                    <dateline xmlns="http://www.tei-c.org/ns/1.0">
                        <placeName/>, <date/>
                    </dateline>
                </sqf:add>
                <sqf:add use-when="tei:opener" match="tei:opener[1]" position="last-child">
                    <dateline xmlns="http://www.tei-c.org/ns/1.0">
                        <placeName/>, <date/>
                    </dateline>
                </sqf:add>
            </sqf:fix>
        </rule>
        <rule
            context="tei:div[@type eq 'document'][.//tei:dateline[not(ancestor::frus:attachment)]//tei:date[@from or @to or @notBefore or @notAfter or @when]]">
            <let name="date-min"
                value="subsequence(.//tei:dateline[not(ancestor::frus:attachment)]//tei:date[@from or @notBefore or @when], 1, 1)/(@from, @notBefore, @when)[. ne ''][1]/string()"/>
            <let name="date-max"
                value="subsequence(.//tei:dateline[not(ancestor::frus:attachment)]//tei:date[@to or @notAfter or @when], 1, 1)/(@to, @notAfter, @when)[. ne ''][1]/string()"/>
            <let name="timezone" value="xs:dayTimeDuration('-PT5H')"/>
            <assert test="@frus:doc-dateTime-min and @frus:doc-dateTime-max"
                sqf:fix="add-doc-dateTime-attributes">Missing @frus:doc-dateTime-min and
                @frus:doc-dateTime-max.</assert>
            <assert
                test="
                    if (@frus:doc-dateTime-min) then
                        frus:normalize-low($date-min, $timezone) eq @frus:doc-dateTime-min
                    else
                        true()"
                sqf:fix="fix-doc-dateTime-min-attribute">Value of @frus:doc-dateTime-min <value-of
                    select="@frus:doc-dateTime-min"/> does not match normalized value of dateline
                    <value-of select="frus:normalize-low($date-min, $timezone)"/>.</assert>
            <assert
                test="
                    if (@frus:doc-dateTime-max) then
                        frus:normalize-high($date-max, $timezone) eq @frus:doc-dateTime-max
                    else
                        true()"
                sqf:fix="fix-doc-dateTime-max-attribute">Value of @frus:doc-dateTime-max <value-of
                    select="@frus:doc-dateTime-max"/> does not match normalized value of dateline
                    <value-of select="frus:normalize-high($date-max, $timezone)"/>.</assert>
            <sqf:fix id="add-doc-dateTime-attributes" role="add">
                <sqf:description>
                    <sqf:title>Add missing @frus:doc-dateTime-min and @frus:doc-dateTime-max
                        attributes</sqf:title>
                </sqf:description>
                <sqf:add target="frus:doc-dateTime-min" node-type="attribute"
                    select="frus:normalize-low($date-min, $timezone)"/>
                <sqf:add target="frus:doc-dateTime-max" node-type="attribute"
                    select="frus:normalize-high($date-max, $timezone)"/>
            </sqf:fix>
            <sqf:fix id="fix-doc-dateTime-min-attribute" role="replace">
                <sqf:description>
                    <sqf:title>Fix @frus:doc-dateTime-min attribute</sqf:title>
                </sqf:description>
                <sqf:replace match="@frus:doc-dateTime-min" target="frus:doc-dateTime-min"
                    node-type="attribute" select="frus:normalize-low($date-min, $timezone)"/>
            </sqf:fix>
            <sqf:fix id="fix-doc-dateTime-max-attribute" role="replace">
                <sqf:description>
                    <sqf:title>Fix @frus:doc-dateTime-max attribute</sqf:title>
                </sqf:description>
                <sqf:replace match="@frus:doc-dateTime-max" target="frus:doc-dateTime-max"
                    node-type="attribute" select="frus:normalize-high($date-max, $timezone)"/>
            </sqf:fix>
        </rule>
        <rule context="tei:div[@frus:doc-dateTime-min]">
            <assert role="error" test="./@frus:doc-dateTime-min castable as xs:dateTime"
                >@frus:doc-dateTime-min must be castable as dateTime</assert>
            <assert role="error" test="./@frus:doc-dateTime-max">div must have both
                @frus:doc-dateTime-min and @frus:doc-dateTime-max</assert>
        </rule>
        <rule context="tei:div[@frus:doc-dateTime-max]">
            <assert role="error" test="./@frus:doc-dateTime-max castable as xs:dateTime"
                >@frus:doc-dateTime-max must be castable as dateTime</assert>
            <assert role="error" test="./@frus:doc-dateTime-min">div must have both
                @frus:doc-dateTime-min and @frus:doc-dateTime-max</assert>
        </rule>
    </pattern>

    <!-- [Work-In-Progress] Unencoded Date Checks -->
    <pattern id="unencoded-dates">
        <title>Unencoded Dates Checks</title>

        <!-- For Documents and Attachments without `date`, Look for Unencoded Dates in Closers -->
        <rule
            context="(tei:div[attribute::subtype eq 'historical-document'] | frus:attachment)[not(descendant::tei:date) and not(descendant::tei:quote)]/tei:closer[not(descendant::tei:dateline)]">
            <assert role="info"
                test="not(.[matches(., '(the\s+)?\d{1,2}(st|d|nd|rd|th)?\s+(of\s+)?(January|February|March|April|May|June|July|August|September|October|November|December),?\s+\d{4}|((January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2}(st|d|nd|rd|th)?,?\s+\d{4})')])"
                >[FYI] This closer possibly contains an unencoded dateline/date.</assert>
            <assert role="info"
                test="not(.[matches(., '(le\s+)?\d{1,2}(eme|ème|re)?\s+(de\s+)?(janvier|février|fevrier|mart|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre),?\s+\d{4}|((janvier|février|fevrier|mart|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre)\s+\d{1,2}(eme|ème|re)?,?\s+\d{4})')])"
                >[FYI] This closer possibly contains an unencoded French-language
                dateline/date.</assert>
        </rule>

        <!-- For Dates without Attributes -->
        <rule context="tei:date[not(attribute::*)]">
            <!-- dates from/to, in English -->
            <let name="month-eng"
                value="('january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december')"/>
            <let name="month-machine-readable-eng"
                value="('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')"/>
            
            <!-- dates from/to, in French -->
            <let name="month-fr" value="('janvier', 'février', 'fevrier', 'mart', 'avril', 'mai', 'juin', 'juillet', 'août', 'aout', 'septembre', 'octobre', 'novembre', 'décembre', 'decembre')"/>
            <let name="month-machine-readable-fr"
                value="('01', '02', '02', '03', '04', '05', '06', '07', '08', '08', '09', '10', '11', '12', '12')"/>
            
            <!-- dates from/to, in Spanish -->
            <let name="month-sp" value="('enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'setiembre', 'octubre', 'noviembre', 'diciembre')"/>
            <let name="month-machine-readable-eng"
                value="('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')"/>

            <assert role="warn"
                test="not(.[matches(., '(the\s+)?(\d{1,2})(st|d|nd|rd|th)?\s+(of\s+)?(january|february|march|april|may|june|july|august|september|october|november|december),?\s+\d{4}|((january|february|march|april|may|june|july|august|september|october|november|december)\s+\d{1,2}(st|d|nd|rd|th)?,?\s+\d{4})','i')])"
                sqf:fix="add-when-attribute">This &lt;date&gt; contains a date phrase that could be
                used for @when.</assert>
            <assert role="warn"
                test="not(.[matches(., '(le\s+)?\d{1,2}(eme|ème|re)?\s+(de\s+)?(janvier|février|fevrier|mart|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre),?\s+\d{4}|((janvier|février|fevrier|mart|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre)\s+\d{1,2}(eme|ème|re)?,?\s+\d{4})', 'i')])"
                sqf:fix="add-when-attribute">This &lt;date&gt; contains a French-language date
                phrase that could be used for @when.</assert>
            <assert role="warn"
                test="not(.[matches(., '(el\s+)?\d{1,2}\s+((de|del)\s+)?(enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|setiembre|octubre|noviembre|diciembre),?\s+((de|del)\s+)?\d{4}|((enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|setiembre|octubre|noviembre|diciembre)\s+\d{1,2},?\s+\d{4})', 'i')])"
                sqf:fix="add-when-attribute">This &lt;date&gt; contains a Spanish-language date
                phrase that could be used for @when.</assert>

            <!-- Fix 1: month-day-year-regex-eng -->
            <sqf:group id="add-when-attribute">

                <sqf:fix
                    use-when="matches(., '((January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2})(d|nd|rd|st|th)*,?\s+(\d{4}))', 'i')"
                    id="add-when-attribute-MMDDYYYY-eng">
                    <let name="date-match"
                        value="analyze-string(., '((January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2})(d|nd|rd|st|th)*,?\s+(\d{4}))', 'i')"/>
                    <let name="date-match-1" value="$date-match/fn:match[1]"/>
                    <let name="year" value="$date-match-1//fn:group[attribute::nr eq '5']"/>
                    <let name="month" value="$date-match-1//fn:group[attribute::nr eq '2']"/>
                    <let name="month-digit"
                        value="functx:replace-multi(lower-case($month), $month-eng, $month-machine-readable-eng)"/>
                    <let name="date"
                        value="format-number($date-match-1//fn:group[attribute::nr eq '3'], '00')"/>
                    <let name="when" value="concat($year, '-', $month-digit, '-', $date)"/>
                    <sqf:description>
                        <sqf:title>Add when &lt;attribute&gt; to &lt;date&gt;</sqf:title>
                    </sqf:description>
                    <sqf:add match="." node-type="attribute" target="when" select="$when"/>
                </sqf:fix>

                <!-- Fix 2: day-month-year-regex-eng -->
                <!-- Work-in-progress -->
                <sqf:fix
                    use-when="matches(., '(the\s+)?(\d{1,2}(d|nd|rd|st|th)*\s+(of\s+)?(January|February|March|April|May|June|July|August|September|October|November|December),?\s+(\d{4}))', 'i')"
                    id="add-when-attribute-DDMMYYYY-eng">
                    <let name="date-match"
                        value="analyze-string(., '(the\s+)?(\d{1,2}(d|nd|rd|st|th)*\s+(of\s+)?(January|February|March|April|May|June|July|August|September|October|November|December),?\s+(\d{4}))', 'i')"/>
                    <let name="date-match-1" value="$date-match/fn:match[1]"/>
                    <let name="year" value="$date-match-1//fn:group[attribute::nr eq '6']"/>
                    <let name="month" value="$date-match-1//fn:group[attribute::nr eq '5']"/>
                    <let name="month-digit"
                        value="functx:replace-multi(lower-case($month), $month-eng, $month-machine-readable-eng)"/>
                    <let name="date"
                        value="format-number($date-match-1//fn:group[attribute::nr eq '1'], '00')"/>
                    <let name="when" value="concat($year, '-', $month-digit, '-', $date)"/>
                    <sqf:description>
                        <sqf:title>Add when &lt;attribute&gt; to &lt;date&gt;</sqf:title>
                    </sqf:description>
                    <sqf:add match="." node-type="attribute" target="when" select="$when"/>
                </sqf:fix>
            </sqf:group>
        </rule>

        <!-- For Unencoded PlaceNames in Datelines -->
        <rule context="tei:dateline[not(descendant::tei:placeName)]">
            <!-- TODO: Add cities from normalized harvested list -->
            <assert role="info" test=".[not(matches(., '(Athens|Quito|Rome)'))]">This dateline contains a
                candidate for &lt;placeName&gt;.</assert>
        </rule>


        <!-- For Documents and Attachments without `date`, Look for Unencoded Dates in Last Paragraphs -->
        <rule
            context="(tei:div[attribute::subtype eq 'historical-document'] | frus:attachment)[not(descendant::tei:date) and not(descendant::tei:quote)]/tei:p[position() = last()]">
            <let name="last-paragraph" value="."/>
            <let name="last-paragraph-content" value="./node()"/>
            <let name="line-break" value="element(tei:lb)"/>
            <let name="closer-dateline" value="element(tei:closer)/element(tei:dateline)"/>
            <assert role="info"
                test="not(.[matches(., '(the\s+)?\d{1,2}(st|d|nd|rd|th)?\s+(of\s+)?(January|February|March|April|May|June|July|August|September|October|November|December),?\s+(\d{4})|((January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2}(st|d|nd|rd|th)?,?\s+\d{4})')])"
                sqf:fix="fix-date-in-last-paragraph">[FYI] This paragraph possibly contains an
                unencoded dateline/date.</assert>
            <assert role="info"
                test="not(.[matches(., '(le\s+)?\d{1,2}(eme|ème|re)?\s+(de\s+)?(janvier|février|fevrier|mart|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre),?\s+\d{4}|((janvier|février|fevrier|mart|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre)\s+\d{1,2}(eme|ème|re)?,?\s+\d{4})')])"
                sqf:fix="fix-date-in-last-paragraph">[FYI] This paragraph possibly contains an
                unencoded French-language dateline/date.</assert>
            <assert role="info"
                test="not(.[matches(., '(el\s+)?\d{1,2}\s+((de|del)\s+)?(enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|setiembre|octubre|noviembre|diciembre),?\s+((de|del)\s+)?\d{4}|((enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|setiembre|octubre|noviembre|diciembre)\s+\d{1,2},?\s+\d{4})')])"
                sqf:fix="fix-date-in-last-paragraph">[FYI] This paragraphe possibly contains an
                unencoded Spanish-language dateline/date.</assert>

            <sqf:group id="fix-date-in-last-paragraph">

                <!-- Last Paragraph: Fix 1a -->
                <sqf:fix id="convert-p-to-closer-dateline">
                    <sqf:description>
                        <sqf:title>Convert last paragraph to closer/dateline</sqf:title>
                        <sqf:p>Convert last &lt;p&gt; to &lt;closer/dateline&gt; in the current
                            document; retain node content</sqf:p>
                    </sqf:description>
                    <sqf:replace use-when=".[not(following-sibling::tei:closer)]"
                        node-type="element" target="tei:closer">
                        <dateline xmlns="http://www.tei-c.org/ns/1.0" rendition="#left">
                            <sqf:copy-of select="$last-paragraph-content"/>
                        </dateline>
                    </sqf:replace>
                </sqf:fix>

                <!-- Last Paragraph: Fix 1b -->
                <sqf:fix id="add-dateline-in-existing-closer">
                    <sqf:description>
                        <sqf:title>Add paragraph content as `dateline` in existing
                            `closer`</sqf:title>
                        <sqf:p>Add &lt;p&gt; content as `dateline` in existing &lt;closer&gt;;
                            retain node content</sqf:p>
                    </sqf:description>
                    <sqf:add use-when=".[following-sibling::tei:closer]"
                        match="./following-sibling::tei:closer" position="first-child">
                        <dateline xmlns="http://www.tei-c.org/ns/1.0" rendition="#left">
                            <sqf:copy-of select="$last-paragraph-content"/>
                        </dateline><lb xmlns="http://www.tei-c.org/ns/1.0"/>
                    </sqf:add>
                    <sqf:delete match="."/>
                </sqf:fix>

            </sqf:group>
        </rule>

        <!-- For Documents and Attachments without `date`, Look for Unencoded Dates in Postscripts -->
        <rule
            context="tei:postscript[not(parent::tei:div[attribute::subtype = ('editorial-note', 'errata')]) and not(parent::tei:div[descendant::tei:date]) and not(parent::frus:attachment[descendant::tei:date]) and not(parent::tei:quote)]">
            <assert role="info"
                test="not(.[matches(., '(the\s+)?\d{1,2}(st|d|nd|rd|th)?\s+(of\s+)?(January|February|March|April|May|June|July|August|September|October|November|December),?\s+\d{4}|((January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2}(st|d|nd|rd|th)?,?\s+\d{4})')])"
                sqf:fix="fix-date-in-postscript">[FYI] This postscript possibly contains an
                unencoded dateline/date.</assert>
            <assert role="info"
                test="not(.[matches(., '(le\s+)?\d{1,2}(eme|ème|re)?\s+(de\s+)?(janvier|février|fevrier|mart|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre),?\s+\d{4}|((janvier|février|fevrier|mart|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre)\s+\d{1,2}(eme|ème|re)?,?\s+\d{4})')])"
                sqf:fix="fix-date-in-postscript">[FYI] This postscript possibly contains an
                unencoded French-language dateline/date.</assert>
            <assert role="info"
                test="not(.[matches(., '(el\s+)?\d{1,2}\s+((de|del)\s+)?(enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|setiembre|octubre|noviembre|diciembre),?\s+((de|del)\s+)?\d{4}|((enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|setiembre|octubre|noviembre|diciembre)\s+\d{1,2},?\s+\d{4})')])"
                sqf:fix="fix-date-in-postscript">[FYI] This postscript possibly contains an
                unencoded Spanish-language dateline/date.</assert>

            <let name="postscript" value="."/>
            <let name="postscript-content" value="./tei:p/node()"/>

            <sqf:group id="fix-date-in-postscript">

                <!-- Postscript: Fix 1 -->
                <sqf:fix id="convert-postscript-to-new-closer-dateline">
                    <sqf:description>
                        <sqf:title>Convert &lt;postscript&gt; to new
                            &lt;closer/dateline&gt;</sqf:title>
                        <sqf:p>Convert &lt;postscript&gt; to new &lt;closer/dateline&gt; in the
                            current document; retain node content</sqf:p>
                    </sqf:description>
                    <sqf:replace use-when="." node-type="element" target="tei:closer">
                        <dateline xmlns="http://www.tei-c.org/ns/1.0" rendition="#left">
                            <sqf:copy-of select="$postscript-content"/>
                        </dateline>
                    </sqf:replace>
                </sqf:fix>

                <!-- Postscript: Fix 2 -->
                <sqf:fix id="convert-postscript-to-dateline-in-following-closer">
                    <sqf:description>
                        <sqf:title>Convert &lt;postscript&gt; to &lt;dateline&gt; in the following
                            &lt;closer&gt;</sqf:title>
                        <sqf:p>Convert &lt;postscript&gt; to &lt;dateline&gt; in the preceding
                            &lt;closer&gt; in the current document; retain node content</sqf:p>
                    </sqf:description>
                    <sqf:add use-when=".[following-sibling::tei:closer]"
                        match="./following-sibling::tei:closer" position="first-child">
                        <dateline xmlns="http://www.tei-c.org/ns/1.0" rendition="#left">
                            <sqf:copy-of select="$postscript-content"/>
                        </dateline><lb xmlns="http://www.tei-c.org/ns/1.0"/>
                    </sqf:add>
                    <sqf:delete match="."/>
                </sqf:fix>

                <!-- Postscript: Fix 3 -->
                <sqf:fix id="convert-postscript-to-dateline-in-preceding-closer">
                    <sqf:description>
                        <sqf:title>Convert &lt;postscript&gt; to &lt;dateline&gt; in the preceding
                            &lt;closer&gt;</sqf:title>
                        <sqf:p>Convert &lt;postscript&gt; to &lt;dateline&gt; in the preceding
                            &lt;closer&gt; in the current document; retain node content</sqf:p>
                    </sqf:description>
                    <sqf:add use-when=".[preceding-sibling::tei:closer]"
                        match="./preceding-sibling::tei:closer" position="last-child">
                        <lb xmlns="http://www.tei-c.org/ns/1.0"/><dateline
                            xmlns="http://www.tei-c.org/ns/1.0" rendition="#left">
                            <sqf:copy-of select="$postscript-content"/>
                        </dateline>
                    </sqf:add>
                    <sqf:delete match="."/>
                </sqf:fix>

            </sqf:group>

        </rule>
    </pattern>

    <!-- Functions to normalize dates -->

    <xsl:function name="frus:normalize-low">
        <xsl:param name="date"/>
        <xsl:param name="timezone"/>
        <xsl:choose>
            <xsl:when test="$date castable as xs:dateTime">
                <xsl:value-of select="adjust-dateTime-to-timezone(xs:dateTime($date), $timezone)"/>
            </xsl:when>
            <xsl:when test="$date castable as xs:date">
                <xsl:value-of
                    select="adjust-dateTime-to-timezone(xs:date($date) cast as xs:dateTime, $timezone)"
                />
            </xsl:when>
            <xsl:when test="matches($date, '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$')">
                <xsl:value-of
                    select="adjust-dateTime-to-timezone(xs:dateTime($date || ':00'), $timezone)"/>
            </xsl:when>
            <xsl:when test="matches($date, '^\d{4}-\d{2}$')">
                <xsl:value-of
                    select="adjust-dateTime-to-timezone(xs:dateTime($date || '-01T00:00:00'), $timezone)"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="adjust-dateTime-to-timezone(xs:dateTime($date || '-01-01T00:00:00'), $timezone)"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="frus:normalize-high">
        <xsl:param name="date"/>
        <xsl:param name="timezone"/>
        <xsl:choose>
            <xsl:when test="$date castable as xs:dateTime">
                <xsl:value-of select="adjust-dateTime-to-timezone(xs:dateTime($date), $timezone)"/>
            </xsl:when>
            <xsl:when test="$date castable as xs:date">
                <xsl:value-of
                    select="adjust-dateTime-to-timezone(xs:date($date) cast as xs:dateTime, $timezone) + xs:dayTimeDuration('PT23H59M59S')"
                />
            </xsl:when>
            <xsl:when test="matches($date, '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$')">
                <xsl:value-of
                    select="adjust-dateTime-to-timezone(xs:dateTime($date || ':59'), $timezone)"/>
            </xsl:when>
            <xsl:when test="matches($date, '^\d{4}-\d{2}$')">
                <xsl:value-of
                    select="adjust-dateTime-to-timezone(xs:dateTime($date || '-' || functx:days-in-month($date || '-01') || 'T23:59:59'), $timezone)"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="adjust-dateTime-to-timezone(xs:dateTime($date || '-12-31T23:59:59'), $timezone)"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="functx:days-in-month" as="xs:integer?" xmlns:functx="http://www.functx.com">
        <xsl:param name="date" as="xs:anyAtomicType?"/>

        <xsl:sequence
            select="
                if (month-from-date(xs:date($date)) = 2 and functx:is-leap-year($date)) then
                    29
                else
                    (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[month-from-date(xs:date($date))]"/>

    </xsl:function>

    <xsl:function name="functx:is-leap-year" as="xs:boolean" xmlns:functx="http://www.functx.com">
        <xsl:param name="date" as="xs:anyAtomicType?"/>

        <xsl:sequence
            select="
                for $year in xs:integer(substring(string($date), 1, 4))
                return
                    ($year mod 4 = 0 and $year mod 100 != 0) or $year mod 400 = 0"/>

    </xsl:function>

    <xsl:function name="functx:if-absent" as="item()*" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="item()*"/>
        <xsl:param name="value" as="item()*"/>

        <xsl:sequence
            select="
                if (exists($arg)) then
                    $arg
                else
                    $value"/>

    </xsl:function>

    <xsl:function name="functx:replace-multi" as="xs:string?" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="changeFrom" as="xs:string*"/>
        <xsl:param name="changeTo" as="xs:string*"/>

        <xsl:sequence
            select="
                if (count($changeFrom) > 0) then
                    functx:replace-multi(replace($arg, $changeFrom[1], functx:if-absent($changeTo[1], '')), $changeFrom[position() > 1], $changeTo[position() > 1])
                else
                    $arg"/>

    </xsl:function>

    <xsl:function name="frus:date-regex-english" as="xs:anyAtomicType?">
        <xsl:param name="date-element" as="xs:anyAtomicType?"/>

        <xsl:choose>
            <xsl:when
                test="matches($date-element, '((January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2})(d|nd|rd|st|th)*,*\s+(\d{4}))', 'i')">
                <xsl:for-each
                    select="analyze-string($date-element, '((January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2})(d|nd|rd|st|th)*,*\s+(\d{4}))', 'i')/fn:match">


                    <!-- Work in progress, dummy content -->
                    <value-of select="serialize(.)"/>

                </xsl:for-each>

            </xsl:when>
            <xsl:otherwise>

                <!-- Work in progress, dummy content -->
                <value-of select="9999"/>
            </xsl:otherwise>

        </xsl:choose>
    </xsl:function>

</schema>
