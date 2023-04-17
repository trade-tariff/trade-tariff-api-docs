---
title: Using the Commodities API
---

# Using the Commodities API

This guide gives an overview of how to use the most common and useful tariff API, the commodities API.

The JSON:API principles noted in this document also apply to other data objects, such as headings, chapters and  geographical areas, which will be documented in future blog pages.

Please also see the new section on [reference data](/reference-data.html) which provides lookup values 
for regularly-used entities such as:

- measure types
- measure type series
- action codes
- condition codes

## About the commodities API

The commodities API is the most important of all of the APIs. It grants you access to virtually all the content that is present on a commodity code page on the Online Tariff. Along with all the other APIs, it is structured using the [JSON:API convention](https://jsonapi.org/), so that:

- the entire (primary) commodity content is self-contained within one API
- each referenced entity is included only once, rather than multiple times

Some content, such as rules of origin data, is stored in separate APIs.

## Where to find the API

The API is available at the URL:

```
https://www.trade-tariff.service.gov.uk/api/v2/commodities/{10-digit-commodity}
```

So, for example, if you are looking at the API for **cherry tomatoes**, which has a commodity code of **0702000007**, you would access the URL:

```
https://www.trade-tariff.service.gov.uk/api/v2/commodities/0702000007
```

It's easy to remember the URL for the commodities API: it's the same as the URL for the commodity on the Online Tariff, but with `api/v2/` inserted before `commodities`.

If you need to use the Northern Ireland tariff, then insert `xi/` before the `api/v2/`.

## The structure of the commodities API

There are two sections to the commodities API:

- `data`
- `included`

### The data section

The `data` section includes all the primary attributes about the commodity and lists the relationships with other entities that are referenced on the commodity.

|Field|Description|
|-|-|
|id|The unique identifier for the commodity code in the system which produces the data. The `id` field is totally unique, whereas the 10-digit commodity codes may be reused over time, therefore a single id may refer to multiple past, present of future commodity codes, though never present at the same time.|
|type|`commodity` (always)|

#### data : attributes

The attributes section lists the core, intrinsic properties of the commodity code.

|Field|Description|
|-|-|
|producline_suffix|The `producline_suffix` is a structural element that is used to add hierarchical tiers into the tariff, to aid comprehension. Where the `producline_suffix` is set to '80', the commodity code is potentially declarable, where declarable means that the commodity has no descendant commodity codes.<br><br>Where the value of this field is anything other than '80', such as '10', '20', '30', '40' or '50', this means that the item is a structural heading only.<br><br>However, as the commodities API only deals with commodities which are 'declarable', the value of the `producline_suffix` field in this API will always be '80'.<br><br>Measures may only be assigned to goods nomenclature items that have a `producline_suffix` of '80', albeit they may be assigned to items at any point in the hierarchy and then inherited down to descendant codes.<br><br>Headings and subheadings may feature `producline_suffix` values other than '80'.|
|description|The `description` field contains the raw description, as entered into the master tariff management application. There are, on occasion, formatting instructions in this field that have not been rendered into HTML, such as instructions to include superscripts, subscripts or non-breaking spaces.<br><br>Use this field if you want to use the raw data and apply your own formatting to the description.|
|number_indents|The number of indents show how deeply nested in the overall hierarchy the commodity code is.<br><br>The hierarchy starts with an indent of '0' for chapters. '0' is also used for the next tier, headings, and from that point onwards, the number of indents increments by 1 as the hierarchy deepens.|
|goods_nomenclature_item_id|The `goods_nomenclature_item_id` is the commodity code. It always features 10 numeric digits. In this guide, the terms `goods_nomenclature_item_id` and commodity code are synonymous.|
|bti_url|At the point of writing, this field is effectively hard-coded, and points at the URL via which a trader may find out more information on getting an advance tariff ruling or legally binding decision on a goods classification.<br><br>The usage of this field is likely to evolve in the future.|
|formatted_description|This field formats the description field by replacing formatting instructions with HTML equivalents. Typically, this is the description field that should be used in any web-based application, unless there is a very good reason to use one of the other fields.|
|description_plain|As per the description field, but with all formatting instructions removed.|
|consigned|Possible values are `true` or `false`. The field identifies if the commodity is only applicable for goods that are consigned via a specific country (or countries).|
|consigned_from|if the value of consigned is set to `true`, then the `consigned_from` field identifies the country or countries in question.|
|basic_duty_rate|This field includes the basic third country duty rate where that rate is a simple ad valorem (percentage) based duty. This is no longer used on the Online Tariff but is maintained for compatibility purposes. The value of this field is `null` when the basic duty is not ad valorem, or is conditional.|
|meursing_code|This field is only valid on the Northern Ireland tariff, and identifies if the commodity code features any measures that include Meursing-related placeholders. Meursing placeholders are used for complex agri-foods on the Northern Ireland / EU tariff to work out duties based on the percentage content of ingredients (broadly sugar, flour, dairy).|
|validity_start_date|The date from which the commodity code came into effect.|
|validity_end_date|The date when the commodity code is to be closed down. Usually, this is set to `null` for commodities that have no end-date.
|declarable|This field is always set to `true` for commodities, which are by their very nature declarable, having a producline_suffix of `80` and no descendant codes.|


#### data : relationships

The relationships section lists any entities that are referenced by this commodity. Each of these entities is listed in the `included` section of the commodities API, as documented below.

|Field|Description|
|-|-|
|footnotes|Footnotes can be applied in two places: either to a measure, or to a commodity. This section references the zero or more records of type `footnote` that are applied to the commodity, each of which are listed in the `included` section.<br><br>Each measure also has a section where references to footnotes are listed.|
|section|This node references the single section to which a commodity code belongs. There are 21 sections, which act as structural subdivisions to aid in navigating the tariff.<br><br>This node references the node of type `section` in the `included` section.|
|chapter|This node references the single chapter to which a commodity code belongs and references the node of type `chapter` in the `included` section.|
|heading|This node references the single heading to which a commodity code belongs and references the node of type `heading` in the `included` section.|
|ancestors|When a commodity code is nested more than one tier underneath a heading, there are a number of intermediate ancestors between the heading and the selected commodity code which form that ancestor tree.<br><br>This node references zero or more nodes of type `commodity` in the `included` section. The fields in the commodity-type elements in the `included` section are a subset of the fields on the primary commodity API (attributes).|
|import_measures|This is absolutely crucial in understanding the measures that are present on a commodity code. This node lists references to all import measures by their unique ID.<br><br>Each measure is listed in the `included` section of the API with a type of `measure`. This is documented in a lot more detail below.|
|export_measures|As per the import_measures node above, this refers to measure-type objects listed in the `included` section of the API. Measures are most likely either import or export, but there are some, such as supplementary units and some fishing catch certification measures that are both import and export. In this case, the measures are referenced under both `import_measures` and `export_measures`, but included only once in the `included` section.|
|import_trade_summary|This references the single entity of type `import_trade_summary` in the `included` section below.|

#### data : meta

The `data : meta` section is for internal use by the Online Trade Tariff, therefore is not documented here.

### The included section

As noted in the documentation on the data section, the `included` section includes all the secondary data objects that are referenced in the commodity API's `data : relationships` section.

The key object within the included section is the `measure` object. This is documented in detail below. Other objects that are referenced on the measure are documented on the [API Docs reference pages](reference.html), so are not replicated in such detail here.

The important thing is that each object behaves in a similar way, with an `attributes` section for intrinsic properties, and a `relationships` section for referenced entities.

## The measure object

The measure object (and all subsequent objects listed here) is structured similarly to the main commodity object, with core, intrinsic attributes listed under the `attributes` section, with referenced objects being listed under `relationships`.

**measure : attributes**

|Field|Description|
|-|-|
|origin|Historically this was used to differentiate between UK and EU-sourced measures. `eu` for all formerly international trade measures; `uk` for all VAT and excise measures.|
|import|`true` or `false` – most measures are one of import or export, but some are both (supplementary units and catch certificate-related).|
|export|`true` or `false` – as per import measures.|
|id|unique measure identifier.|
|effective_start_date|the date from which the measure was / will be valid.|
|effective_end_date|the date to which the measure was / will be valid. In most cases, the value will be `null`, indicating the measure has no end date.|
|excise|`true` or `false` – `true` if measure is of type `306` (excise).|
|vat|`true` or `false` – `true` if measure is of type `305` (vat).|
|reduction_indicator|used in Meursing calculation on the XI tariff.|
|meursing|used in Meursing calculation on the XI tariff.|
|resolved_duty_expression|used in Meursing calculation on the XI tariff.|
|universal_waiver_applies|if a 999L condition is applied to a measure.|

**measure : relationships**

|Field|Description|
|-|-|
|duty_expression|Contains a reference to the single applicable `duty_expression` object in the `included` section. The duty expression object represents the duty for a tariff or tax measures, which is composed of one or more measure_components.<br><br>A duty_expression object is only included for measures that have duties (as well as supplementary units). Others, such as import controls, do not reference duty_expressions.|
|measure_type|Contains a reference to the single applicable `measure_type` object in the `included` section. Measure types identify what sort of measure is being referenced.<br><br>The full list of measure types is available on the [measure_types API](https://www.trade-tariff.service.gov.uk/api/v2/measure_types) and documented here under [reference data (measure types)](/reference-data.html#measure-types). Some of the key measure types are:<br><br>`103` Third country duty<br>`109` Supplementary unit<br>`142` Tariff preference<br><br>Measure types themselves are grouped according to their `measure type series`, which broadly identifies their usage. Key measure type series are:<br><br>`A` Prohibitions<br>`B` Restrictions<br>`C` Applicable duties<br>`P` VAT<br>`Q` Excise<br><br>Measure type series are documented under [reference data (measure type series)](/reference-data.html#measure-types)|
|legal_acts|Contains a reference to one or more applicable `legal_act` objects in the `included` section. These are the regulations that give the measures legal backing.<br><br>On the UK tariff, there will be just one legal act referenced. On the XI tariff, more than one may be referenced, if the original 'base' regulation has since been modified.|
|measure_conditions|Contains references to zero or more applicable `measure_condition` objects in the `included` section.<br><br>Measure conditions are crucial for a number of reasons, primarily to identify what documentation a trader needs to prepare to successfully meet the requirements of a condition, or the exemptions / exclusions that are in place that may make a document superfluous.<br><br>In addition, there may be thresholds in place, e.g. if a trader is importing below  certain weight threshold of goods, then a document is not needed.<br><br>Duties may also be dependent on measure conditions, e.g. if documents are provided, or if the import price is below certain thresholds.<br><br>See also the section on `measure_condition_permutation_groups` below for more information on complex arrangements of measure conditions.|
|measure_components|Contains a reference to zero or more applicable `measure_component` objects in the `included` section.<br><br>Measure components are the building blocks for duty expressions. A simple ad valorem or specific duty (like 3.60% or £10.00 / KGM) only features one measure component, but more complex compound duties (like 3.60% + £10.00 / KGM) feature multiple measure components.<br><br>In most cases, the `duty_expression` object should suffice, but if there is a need to break the duty expression down into its constituent parts, then use the measure components.|
|geographical_area|Contains a reference to the single applicable `geographical_area` objects in the `included` section. A geographical area is needed ... |
|excluded_countries|Contains a reference to zero or more applicable `geographical_area` objects in the `included` section|
|footnotes|reference to the applicable `footnote` objects in the `included` section|
|order_number|reference to the applicable `order_number` object in the `included` section|
|preference_code|reference to the applicable `preference_code` object in the `included` section|
|measure_condition_permutation_groups|reference to the applicable `measure_condition_permutation_group` objects in the `included` section. In certain controls on certain commodities, measure conditions are applied in a complex manner to cater for occasions where more than one condition needs to be observed in conjunction with another (and relationship).<br><br>This applies to some veterinary controls and controls on the import and export of waste goods.<br><br>[Measure condition permutation groups](/reference.html#measureconditionpermutationgroup) are documented on the main reference pages.

|
|resolved_measure_components|reference to the applicable `resolved_measure_component` objects in the `included` section|
|national_measurement_units|reference to the applicable `national_measurement_unit` objects in the `included` section|



## Accessing measures

The content in this section applies to both import and export measures, however as there are so many more import measures, which themselves have more features than the export equivalents (such as duties), the focus here is on import measures.

Here is a brief sequence of activities that you should perform in your code to derive each of the measures and their properties:

- Retrieve and store a list of all of the references to import measures (or export measures, if you are interested in export).
- For each measure:
  - find the equivalent entity of type `measure` in the `included` section.
  - store the properties (attributes and relationships - i.e. referenced entities).
  - for each of the entities referenced in the relationships part of the measure node:
      - find the referenced entity in the `included` section.
      - store the values of those referenced entities, and if necessary (in most cases it will not be), capture and store the referenced entities in entities.

<hr>

There is an alternative way to capture all import / export measures. Each measure has both an `import` and `export` boolean field (`true` / `false`) to identify if the measure is for import, export or both. You can just search for all measures and use the ones that meet the requirement (import or export).

Generically, there is no more to it, but let's take a couple of examples to bring this to life.

### Working out if measures apply to a given country

The schematic below illustrates if a measure applies to a given country of import (or export).

![Schematic showing if measures apply to a given country](/images/geo.png)

The rules are, for a given geographical area ID (2-digit country):

- is the measure applied direct to the a single country? If so, then the measure is relevant, if not then it is not relevant
- is the measure applied to a geographical area group code with member countries? If so, then:
  - is the import country included in that group?
      - if it is not included, then the measure is not relevant
      - if it is included, then:
          - is the import country excluded from the measure?
              - if so, then the measure is not relevant
              - if not, then the measure is relevant

**So how is this represented in data?**

Let's look at an example commodity code ([0103911000](https://www.trade-tariff.service.gov.uk/api/v2/commodities/0103911000) - domestic swine species). Imagine we are importing 
domestic swine from a European Union member state, such as Belgium.

The image below shows the import controls in place on this commodity:

- an **organic control** on imports from all countries except EU and certain other European countries
- a **veterinary control** on imports from all countries except Ireland
- a **restriction on entry into free circulation** on goods coming from Ukraine

![Schematic showing if measures apply to a given country](/images/0103911000_domestic_swine.png)

You can work out that:

- the **organic control** does not apply to Belgium, as EU states are excluded
- the **veterinary control** does apply to Belgium, as only Ireland is excluded
- the **restriction on entry into free circulation** does not apply to Belgium as it solely references Ukraine

The commodities API for this commodity is available at the URL:

```
https://www.trade-tariff.service.gov.uk/api/v2/commodities/0103911000
```

The country code for Belgium is `BE`.

The core process that your code needs to go through to find out applicability of these controls is:

1. Find all the import measure IDs by accessing `data : relationships : import_measures`

2. Read the detailed data on the import measures, by looking up items of type `measure` in the `included` section, whose IDs match the IDs captured in step 1.

3. Within each of these measures:

   - access the geographical area to which the measure is applied, via the `relationships : geographical_area` node.

   - look up the geographical area in the included section by searching for an entity with an ID the same as the referenced area, and a type of `geographical_area`.

     - if the `children_geographical_areas` node of the referenced geographical area is not populated, then it is a single country or region: if the ID is `BE`, then we know that the measure applies to Belgium and we are finished.

     - however, if that area does contain a populated `children_geographical_areas` node, then it is a group of countries with members. In this case, you need to check if the geographical area (group) contains the country of interest, Belgium. As the country group 1011 which is used for 2 of the measures above **does** contain Belgium, we know that the measure will apply to Belgium, unless Belgium is explicitly excluded.

   - to find geographical area exclusions, i.e. countries that are exempted from a measure that applies to a group to which the country belongs, you need to go back to the measure, and look at the `relationships : excluded_countries` node.

     - if BE is included in the list of excluded countries, then the measure does not apply, as is the case with the organic control

     - but if BE is not in the list of excluded countries, then the measure does apply, as with the veterinary control.

### Find the third-country duty measure and the applicable duty

Let's say we are importing domestic swine from the United States, a country with which the UK does not have a
trade agreement. The import will need to fall back to the third-country duty
(or <abbr title="Most Favoured Nation">MFN</abbr> duty).

The image below shows the third-country duty for the same commodity ([0103911000](https://www.trade-tariff.service.gov.uk/commodities/0103911000)) as in the example above. You will see that there are three measures
pictured:

- **Third-country duty** (for all countries)

- **UK-CD Customs Union** (for goods coming from the Crown Dependencies of Jersey or Guernsey)

- **Tariff preference** (for goods coming from CARIFORUM countries)

![Screen grab showing a third-country duty](/images/0103911000_third_country.png)

The reason this example is chosen is to show the importance of always checking on the geographical applicability of a measure.

A third-country duty has a [measure type](/reference-data.html#measure_types) of `103`. Even though the UK-<abbr title="Crown Dependencies">CD</abbr> Customs Union measure is labelled as such, this is actually also a third-country duty 
measure of type `103`, assigned solely to the Channel Islands which are among the UK's Crown Dependencies: only the label is different on the Online Tariff UI.

Follow these steps to find the third-country measure:

1. Find all the import measure IDs by accessing `data : relationships : import_measures`

2. Read the detailed data on the import measures, by looking up items of type `measure` in the `included` section, whose IDs match the IDs captured in step 1.

3. To find the third-country duty, you are looking for measures that have the measure type `103` referenced in the `relationships : measure_type` node.

    You also need to check on the measure's **geographic applicability** using the method above. In this way, you will bring back the true third-country duty, assigned to group `1011`, which contains USA (`US`) and not the third-country duty assigned to Jersey and Guernsey (group `1080`).

Once you have located the relevant measure of type `103`, you can then find the associated duty. Once again, the information needed can be found through looking at relationships and then looking up the referenced item in the `included` section. In this case:

- Start with the measure.<br><br>Under `relationships : duty_expression`, find the duty expression that relates to the third country duty measure located in the step above. Remember, not all measures have duty expressions, just those that belong to relevant measure types and series (e.g. not control measures).

- The duty expression, if it exists, and it will exist for a measure of type `103`, will reference an object with an ID in form `{measure ID}-duty_expression`. In the example of the swine commodity, at the time of writing, the third country duty measure has an ID of `20000027`, therefore the referenced duty expression is `20000027-duty_expression`. Measure SIDs can change over time, so please do not rely on them remaining static forever.

- Find the entity of type `duty_expression`in the included section that matches the identity of the item found in the previous step. The `duty_expression` node then contains the data that you need to show the duty.

```json
{
  "id": "20000027-duty_expression",
  "type": "duty_expression",
  "attributes": {
    "base": "34.00 GBP / 100 kg",
    "formatted_base": "<span>34.00</span> GBP / <abbr title='Hectokilogram'>100 kg</abbr>",
    "verbose_duty": "£34.00 / 100 kg"
}
```
The `verbose_duty` node is the data that is used on the tariff UI.



### Find all import control measures

We are importing commodity [8415900099](https://www.trade-tariff.service.gov.uk/commodities/8415900099) (air conditioning machine parts, not pre-charged with hydrofluorocarbons) from Belgium, and we want to find all the import controls in place. This includes both **prohibitions** and **restrictions**.

To isolate these two types of control, we need to look for measures that:

- are import measures
- belong to [measure type series](/reference-data.html#measure-type-series) A (prohibitions) and series B (restrictions)
- are applicable to Belgium

We already know how to find measures applicable to a given country, and to pick out the import measures, but we have not seen how to grab a series of measures of a given type for a given purpose.

The process and data elements are very similar to the previous 2 examples.

Access the commodity code API at the following URL:

```
https://www.trade-tariff.service.gov.uk/api/v2/commodities/8415900099
```


1. Find all the import measure IDs by accessing `data : relationships : import_measures`

2. Read the detailed data on the import measures, by looking up items of type `measure` in the `included` section, whose IDs match the IDs captured in step 1.

3. To find prohibition and restriction type measures:

   - look at the measure type for each measure in the `relationships` section of the measure. It looks like this:


    ```json
    "measure_type": {
        "data": {
          "id": "724",
          "type": "measure_type"
        }
      }
    ```
   - look for measures of a type that matches the `id` of the located measure type in the `included` section of the API.
   
  ```json
  {
      "id": "724",
      "type": "measure_type",
      "attributes": {
        "description": "Import control of fluorinated greenhouse gases",
        "measure_type_series_id": "B",
        "measure_component_applicable_code": 2,
        "order_number_capture_code": 2,
        "trade_movement_code": 0,
        "validity_end_date": null,
        "validity_start_date": "2006-07-04T00:00:00.000Z",
        "id": "724",
        "measure_type_series_description": "Entry into free circulation or exportation subject to conditions"
      }
    }
  ```

- The measure type series ID is available in the `attributes` node of the `measure_type` entity.
- If the `measure_type_series_id` matches either `A` or `B`, then you have a prohibitive or restrictive measure.

**Additional codes on measures**

There is an additional feature on the prohibitive measures on this commodity code that is worth pointing out. In a lot of cases, even a 10-digit commodity code is not sufficiently granular to define a product that is being traded. Sometimes there is a need to further subdivide a commodity according to:

   - purpose (e.g. transformation into something else)
   - specific properties (e.g. an individual chemical in a commodity that caters for multiple chemicals, or a specific fur type, or antiquity of artwork etc.)
   - an overseas company from which a commodity has been imported

This is done using `additional codes`, which are 4-character codes that help to define a commodity code further according to one or more of the criteria above. Finding additional codes is handled in much the same way as finding measure types and duties.

If there is an additional code associated with a measure, and this applies to any measure, not just prohibition and restriction measures, then they are accessed from the `relationships : additional_code` part of the measure definition. As with the previous entities, the additional codes have a unique identifier.

Look for the unique identifier on an entity of type `additional_code` in the `included` section and you have your additional code definition. Use the `formatted_description` node for the description of the code.

```json
{
  "id": "14002",
  "type": "additional_code",
  "attributes": {
    "code": "2700",
    "description": "Duty suspension of 0% applies - see footnote for coverage. Please do not use if the MFN import duty rate is 0%.",
    "formatted_description": "Duty suspension of 0% applies - see footnote for coverage. Please do not use if the MFN import duty rate is 0%."
  }
}
```

## An overall approach to parsing the API

If you need to do anything more than just one single task on a commodity API, it's worth capturing and parsing every entity in the `included` section.

As the JSON:API convention includes referenced entities only once, it may be a more efficient approach to:

- parse the whole API response
- store entities in objects of bespoke classes
- build relationships between the entities, according to the relationships expressed in the API response.

## Feedback on this documentation

We would love to hear what you think of this page. If you have any feedback, queries or issues, please contact the team on [hmrc-trade-tariff-support-g@digital.hmrc.gov.uk](mailto:hmrc-trade-tariff-support-g@digital.hmrc.gov.uk).