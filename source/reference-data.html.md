---
title: Reference data
---

# Reference data

## Measure type series

Measure type series are used to group measure types, and therefore measures,
according to their use in the declaration process. The sequence corresponds to the
order against which border systems, such as CDS, should validate a declaration.

For example, if a declaration does not meet the requirements of measure type series `A` (prohibitions), 
then measures pertaining to the remaining series are not addressed.

Measure type series are largely static, i.e. change to the list provided below is extremely rare.

|Series ID|Description|
|-|-|
|A|Importation and/or exportation prohibited|
|B|Entry into free circulation or exportation subject to conditions|
|C|Applicable duty|
|D|Anti-dumping or countervailing duties|
|E|Levies, export refunds and other agricultural amounts|
|F|Additional duty on sugar, flour|
|G|Monetary compensatory amount|
|H|Accession compensatory amount|
|J|Countervailing charge|
|K|Reference price|
|L|Complementary trade mechanism|
|M|Unit price, standard import value, representative price (poultry, sugar)|
|N|Posterior surveillance|
|O|Supplementary unit|
|P|VAT|
|Q|Excises|
|R|Provisional exclusion|
|S|Supplementary amount|
|Z|Archived measure type|


## Measure types

Measures are grouped according to their nature into measure types. Measure types
represent preferences, quotas, non-preferential measures, anti-dumping measures,
surveillance, restrictions on import or export, prohibitions, etc. They are the main
elements that define what a measure is.

This list of measure types is occasionally updated. For the very latest list of measure
types in use, access the [measure types API](https://www.trade-tariff.service.gov.uk/api/v2/measure_types).

### Prohibition-type measures (series A)

If an import or export declaration does not meet the requirements of the applied prohibition-type controls, 
then a trade will not be permitted to proceed.

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|277|Import prohibition|Import|A|
|278|Export prohibition|Export|A|
|481|Declaration of subheading submitted to restrictions (import)|Import|A|
|485|Declaration of subheading submitted to restrictions (export)|Export|A|

### Restriction / control-type measures (series B)

Restrictive controls permit a trade to proceed under certain conditions, e.g.

- provision of a certificate or licence in the form of an electronic document code;
- submission of exemption to a measure, via an exemption-type document code;
- adherence to threshold controls (e.g. weight or volume) 

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|350|Animal Health Certificate|Import|B|
|351|Health and Safety Executive Import Licensing Firearms and Ammunition|Import|B|
|352|Attestation Document (horticulture and potatoes)|Import|B|
|353|DCMS Open General Export Licence|Export|B|
|354|Home Office Controlled Drugs (export)|Export|B|
|355|HMI Conformity Certificate (fruit and veg) issued in UK|Import|B|
|356|Common Veterinary Entry Document (CVED)|Import|B|
|357|Certificate of Conformity|Export|B|
|358|Home Office pre-cursor chemical authorisation|Import|B|
|359|Health and Safety Executive (imports)|Import|B|
|360|Phytosanitary Certificate (import)|Import|B|
|361|Home Office Pre-cursor chemicals|Export|B|
|362|Home Office Controlled Drugs (import)|Import|B|
|363|Quarantine Release Certificate|Import|B|
|410|Veterinary control|Import|B|
|420|Entry into free circulation (prior surveillance)|Import|B|
|464|Declaration of subheading submitted to authorised use provisions|Import|B|
|465|Restriction on entry into free circulation|Import|B|
|467|Restriction on export|Export|B|
|473|Export authorization|Export|B|
|474|Entry into free circulation (quantitative limitation)|Import|B|
|475|Restriction on entry into free circulation|Import|B|
|476|Restriction on export|Export|B|
|477|Entry into free circulation (outward processing traffic)|Import|B|
|478|Export authorization (Dual use)|Export|B|
|479|Export control on dangerous chemicals|Export|B|
|482|Declaration of subheading submitted to restrictions (net weight/supplementary unit)|Import, Export|B|
|483|Declaration of subheading submitted to restrictions (value)|Import, Export|B|
|705|Import prohibition on goods for torture and repression|Import|B|
|706|Goods for torture and repression, export prohibition|Export|B|
|707|Import control|Import|B|
|708|Goods for torture and repression, export restriction|Export|B|
|709|Export control|Export|B|
|710|Import control - CITES|Import|B|
|711|Import control on restricted goods and technologies|Import|B|
|712|Import control - IAS|Import|B|
|713|Import control on genetically modified organisms (GMO) and products containing GMOs|Import|B|
|714|Import control|Import|B|
|715|Export control - CITES|Export|B|
|716|Export control measure for fish|Export|B|
|717|Export control on restricted goods and technologies|Export|B|
|718|Export control on luxury goods|Export|B|
|719|Control on illegal, unreported and unregulated fishing|Import, Export|B|
|722|Entry into free circulation (restriction - feed and food)|Import|B|
|724|Import control of fluorinated greenhouse gases|Import|B|
|725|Export control on ozone-depleting substances|Export|B|
|728|Import control on luxury goods|Import|B|
|730|Compliance with the pre-export checks requirements|Import|B|
|735|Export control on cultural goods|Export|B|
|740|Export control on cat and dog fur|Export|B|
|745|Import control on cat and dog fur|Import|B|
|746|Import control on seal products|Import|B|
|747|Import control of timber and timber products subject to the FLEGT licensing scheme|Import|B|
|748|Import control of mercury|Import|B|
|749|Export control of mercury|Export|B|
|750|Import control of organic products|Import|B|
|751|Export control - Waste|Export|B|
|755|Import control - waste|Import|B|
|760|Import control|Import|B|
|761|Import control on REACH|Import|B|
|766|Export control|Export|B|
|770|Import control of timber and timber products subject to the FLEGT licensing scheme-Ghana|Import|B|
|771|Import control of timber and timber products subject to the FLEGT licensing scheme-Cameroon|Import|B|
|772|Import control of timber and timber products subject to the FLEGT licensing scheme-Republic of Congo|Import|B|
|773|Import control of timber and timber products subject to the FLEGT licensing scheme-Central Africa Republic|Import|B|
|774|Import control of timber and timber products subject to the FLEGT licensing scheme-Vietnam|Import|B|

### Applicable duty-type measures (series C)

This series features the majority of the standard duty-giving measures, such as third
country duties (MFNs), tariff preferences and quotas.

Border systems, such as CDS, will only start to calculate duties once prohibitive and restrictive measure requirements have been passed.

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|103|Third country duty|Import|C|
|105|Non preferential duty under authorised use|Import|C|
|106|Customs Union Duty|Import|C|
|112|Autonomous tariff suspension|Import|C|
|115|Autonomous suspension under authorised use|Import|C|
|117|Suspension - goods for certain categories of ships, boats and other vessels and for drilling or production platforms|Import|C|
|119|Airworthiness tariff suspension|Import|C|
|122|Non preferential tariff quota|Import|C|
|123|Non preferential tariff quota under authorised use|Import|C|
|140|Outward processing tariff preference|Import|C|
|141|Preferential suspension|Import|C|
|142|Tariff preference|Import|C|
|143|Preferential tariff quota|Import|C|
|144|Preferential ceiling|Import|C|
|145|Preference under authorised use|Import|C|
|146|Preferential tariff quota under authorised use|Import|C|
|147|Customs Union Quota|Import|C|

### Anti-dumping or countervailing duties-type measures (series D)

Measures of types 551 to 554 are in regular use on the UK tariff to apply
[trade defence / remedy measures](https://www.gov.uk/government/publications/what-are-trade-remedies/factsheet-what-are-trade-remedies).
The remainder of the measures listed below are used more sparingly on the Northern Ireland tariff.

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|551|Provisional anti-dumping duty|Import|D|
|552|Definitive anti-dumping duty|Import|D|
|553|Provisional countervailing duty|Import|D|
|554|Definitive countervailing duty|Import|D|
|555|Anti-dumping/countervailing duty - Pending collection|Import|D|
|561|Notice of initiation of an anti-dumping or countervailing proceeding|Import|D|
|562|Suspended anti-dumping or countervailing duty|Import|D|
|564|Anti-dumping or countervailing registration|Import|D|
|565|Anti-dumping/countervailing review|Import|D|
|566|Anti-dumping/countervailing statistic|Import|D|
|570|Anti-dumping/countervailing duty - Control|Import|D|

### Levies, export refunds and other agricultural amounts-type measures (series E)

Used in determining duties associated with Meursing placeholders, which are used for complex agri-foods on the Northern Ireland / EU tariff, based on the percentage content of ingredients (broadly sugar, flour, dairy).

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|674|Agricultural component|Import|E|

### Additional duty on sugar, flour (series F)

As with series E, used in determining duties associated with Meursing placeholders, which are used for complex agri-foods on the Northern Ireland / EU tariff, based on the percentage content of ingredients (broadly sugar, flour, dairy).

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|672|Amount of additional duty on sugar|Import|F|
|673|Amount of additional duty on flour|Import|F|

### Countervailing charge-type measures (series J)

Retaliatory and safeguard duties, e.g. those used on steel safeguard duties.

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|695|Additional duties|Import|J|
|696|Additional duties (safeguard)|Import|J|

### Unit price, standard import value, representative price (poultry, sugar) measures (series M)

Duties applied to the import of agricultural goods (certain fruit, vegetables and poultry)

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|488|Unit price|Import|M|
|489|Representative price|Import|M|
|490|Standard import value|Import|M|

### Posterior surveillance-type measures (series N)

Measures put in place to identify a requirement to surveil trade, including credibility checks.

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|430|Control of particulars of the declaration (suspicious value/net weight or value/supplementary unit)|Import|N|
|431|Control of particulars of the declaration (suspicious net weight/supplementary unit)|Import|N|
|440|Public Import Monitoring|Import|N|
|445|Public Export Monitoring|Export|N|

### Supplementary unit-type measures (series O)

Measures to indicate that an additional unit is required on a declaration in order to satisfy duty calculation requirements or surveillance needs.

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|109|Supplementary unit|Import, Export|O|
|110|Supplementary unit import|Import|O|

### VAT-type measures (series P)

VAT only

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|305|Value added tax|Import|P|

### Excises-type measures (series Q)

Excise only

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|306|Excises|Import|Q|


### Supplementary amount-type measures (series S)

Quotas and securities required on the import of poultry (Northern Ireland tariff only)

|ID|Description|Import&nbsp;/&nbsp;export|
|-|-|-|
|651|Security based on representative price|Import|S|
|652|Additional duty based on cif price|Import|S|
|653|Security based on representative price, reduced under the benefit of a tariff quota|Import|S|
|654|Additional duty based on CIF price, reduced under the benefit of a tariff quota|Import|S|
|655|Security (poultry) based on representative price|Import|S|
|656|Additional duty (poultry) based on cif price|Import|S|
|657|Reduced security based on representative price|Import|S|
|658|Reduced additional duty based on CIF price|Import|S|


## Measure action codes

Measure action codes illustrate how CDS (and other border systems) will act in 
response to measure conditions being met or not met.

|Action code|Description|
|-|-|
|01|Apply the amount of the action (see components)|
|02|Apply the difference between the amount of the action (see components) and the price at import|
|03|Apply the difference between the amount of the action (see components) and CIF price|
|04|The entry into free circulation is not allowed|
|05|Export is not allowed|
|06|Import is not allowed|
|07|Measure not applicable|
|08|Declared subheading not allowed|
|09|Import/export not allowed after control|
|10|Declaration to be corrected - box 33, 37, 38, 41 or 46 incorrect|
|11|Apply the difference between the amount of the action (see components) and the free at frontier price before duty|
|12|Apply the difference between the amount of the action (see components) and the CIF price before duty|
|13|Apply the difference between the amount of the action (see components) and the CIF price augmented with the duty to be paid per tonne|
|14|The exemption/reduction of the anti-dumping duty is not applicable|
|15|Apply the difference between the amount of the action (see components) and the price augmented with the countervailing duty (3,8%)|
|16|Export refund not applicable|
|24|Entry into free circulation allowed|
|25|Export allowed|
|26|Import allowed|
|27|Apply the mentioned duty|
|28|Declared subheading allowed|
|29|Import/export allowed after control|
|30|Suspicious case|
|34|Apply exemption/reduction of the anti-dumping duty|
|36|Apply export refund|

## Measure condition codes

A condition code identifies what sort of condition is to be fulfilled in order for the action to be carried out, for example the presentation of a licence or other document, or the meeting of a threshold requirement.

|Condition code|Description|
|-|-|
|A|Presentation of an anti-dumping/countervailing document|
|B|Presentation of a certificate/licence/document|
|C|Presentation of a certificate/licence/document|
|D|Intended for processing|
|E|The quantity or the price per unit declared, as appropriate, is equal or less than the specified maximum, or presentation of the required document|
|F|The net free at frontier price before duty must be equal to or greater than the minimum price (see components)|
|G|The CIF price plus the duty to be paid/ton must be equal to or greater than the minimum price (see components)|
|H|Presentation of a certificate/licence/document|
|I|The quantity or the price per unit declared, as appropriate, is equal or less than the specified maximum, or presentation of the required document|
|K|Also applicable simultaneously with tariff quota shown in the field "certificates"|
|L|CIF price must be higher than the minimum price (see components)|
|M|Declared price must be equal to or greater than the minimum price/reference price (see components)|
|N|The CIF price before duty must be equal to or greater than the minimum price (see components)|
|P|Only particular ingredients are eligible for export refund|
|Q|Presentation of an endorsed certificate/licence|
|R|Ratio "net weight/supplementary unit" is equal to or higher than the condition amount|
|S|Lodgement of a security|
|U|Ratio "declared value/supplementary unit" should be higher than the condition amount|
|V|Import price must be equal to or greater than the entry price (see components)|
|W|Washington Convention|
|Y|Other conditions|
|Z|Presentation of more than one certificate|
