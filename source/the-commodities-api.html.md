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

## Finding all units

It may be necessary to find all the units that are present on a commodity code, for example to calculate duties in an external application, or to see what thresholds are in place for import or export controls.

These units appear in two places in the API:

- in measure component nodes
- in measure condition nodes

### Units and measure components

Let's say you are building an application which will calculate duties, and in order to calculate the duties successfully, you need to ask the user to supply a number of units. These units may be requested already in supplementary unit measures, applied as measures to the commodity code in question, but this is not always the case, e.g. when the units are conditional on (for example) origin or tax type.

If a measure is duty-related, then it will be accompanied by one or more measure components, or in exceptional circumstances, by measure condition components.

- A measure component is a logical part of a duty, sometimes known as a duty expression.
- A duty may be made up of one or more measure components.
- Each measure component features the following key fields:

|Field|Notes|
|-|-|
|duty_expression_id|This determines the kind of duty that is being expressed|
|duty_amount|The unit associated with the component (e.g. the 3 in 3.00% or the 15 in £15.00 / kilogramme)|
|monetary_unit_code|If the unit is specific (e.g. £15.00 / kilogramme), then this is GBP on the UK tariff, or EUR on the XI tariff.<br><br>If the unit is ad valorem (e.g. 3.00%), then the value is `null`|
|measurement_unit_code|This is the crucial field for this purpose.<br><br>If this value is populated, then it may be necessary to ask the user the value associated with this unit in their trade.<br><br>[List of all measurement units](/reference-data.html#measurement-units).|
|measurement_unit_qualifier_code|It may also be the case that a unit on its own is insufficent to describe in full the requirement, therefore an additional qualifier is required.<br><br>For example, for weights, it may be that there is a need to include a qualifier for net, gross or dried weight.<br><br>[List of all measurement unit qualifiers](/reference-data.html#measurement-unit-qualifiers).|

On many occasions, there are multiple units which are actually requesting the same thing from the user, just in multiples. For example:

- `KGM` and `DTN` are the same unit axis (weight), one is just a 100 * multiple of the other.
- `LTR` and `HLT` similarly, but for volumes

Therefore, there is no value in asking the user both `KGM` and `DTN`, as one can be determined from the other. Similalry, with `LTR` and `HLT`

By way of example, let's look at the commodity code for [Cava (2204101300)](https://www.trade-tariff.service.gov.uk/commodities/2204101300). If you look at the public-facing web page, you will see that there are multiple measures that feature units:

- third country duty that mentions 100 litres (`HLT`)
- supplementary unit (global) of litres (`LTR`)
- excise duties which refer to both litres (`LTR`) and litres of pure alcohol (`LPA`)

Let's look at a couple of these in the [commodities API for Cava](https://www.trade-tariff.service.gov.uk/api/v2/commodities/2204101300).

The third country duty measure, which has an ID of `20002430` (at the time of writing) features a single measure component. This is referenced in the `relationships` part of the measure node, and is available via the node of type `measure_component`.

The ID of this node is a compound of the measure's ID and the duty expression ID, as follows:

```json
{
  "id": "20002430-01",
  "type": "measure_component",
  "attributes": {
    "duty_expression_id": "01",
    "duty_amount": 26,
    "monetary_unit_code": "GBP",
    "monetary_unit_abbreviation": null,
    "measurement_unit_code": "HLT",
    "measurement_unit_qualifier_code": null,
    "duty_expression_description": "% or amount",
    "duty_expression_abbreviation": "%"
  },
  "relationships": {
    "measurement_unit": {
      "data": {
        "id": "HLT",
        "type": "measurement_unit"
      }
    },
    "measurement_unit_qualifier": {
      "data": null
    }
  }
}
```

In turn, the unit `HLT` is referenced and the detail, if needed, can be found elsewhere in the `included` section of the same commodity's API.

Similarly, the excise code that references LPA is captured here, in the measure component associated with the measure's ID (`-1011988603`).

Please note: all VAT and excise measures have a negative identifier: all other measures' identifiers are positive.

```json
{
  "id": "-1011988603-01",
  "type": "measure_component",
  "attributes": {
    "duty_expression_id": "01",
    "duty_amount": 28.74,
    "monetary_unit_code": "GBP",
    "monetary_unit_abbreviation": null,
    "measurement_unit_code": "LPA",
    "measurement_unit_qualifier_code": null,
    "duty_expression_description": "% or amount",
    "duty_expression_abbreviation": "%"
  },
  "relationships": {
    "measurement_unit": {
      "data": {
        "id": "LPA",
        "type": "measurement_unit"
      }
    },
    "measurement_unit_qualifier": {
      "data": null
    }
  }
}
```

An example of where a qualifier unit is used in on the commodity code for [Corn cobs 0710400020](https://www.trade-tariff.service.gov.uk/commodities/0710400020).

At the point of writing, the third country duty for corn cobs is `4.00% + £7.80 / 100 kg, drained net weight (kg/net eda)`, which is a combination of a measurement unit code (`DTN`) and qualifier code (`E`).

This has a measure ID of `20001091`. In this instance, there are two measure components, which are again referenced from the measure object itself. These use the duty expression IDs `01` and `04` in order.

The two components in the API are as follows:

- the first is an ad valorem duty, therefore there is no unit (4.00%)
- however, the second is a specific duty with both a unit and unit qualifier.

```json
{
  "id": "20001091-01",
  "type": "measure_component",
  "attributes": {
    "duty_expression_id": "01",
    "duty_amount": 4,
    "monetary_unit_code": null,
    "monetary_unit_abbreviation": null,
    "measurement_unit_code": null,
    "measurement_unit_qualifier_code": null,
    "duty_expression_description": "% or amount",
    "duty_expression_abbreviation": "%"
  },
  "relationships": {}
},
{
  "id": "20001091-04",
  "type": "measure_component",
  "attributes": {
    "duty_expression_id": "04",
    "duty_amount": 7.8,
    "monetary_unit_code": "GBP",
    "monetary_unit_abbreviation": null,
    "measurement_unit_code": "DTN",
    "measurement_unit_qualifier_code": "E",
    "duty_expression_description": "+ % or amount",
    "duty_expression_abbreviation": "+"
  },
  "relationships": {
    "measurement_unit": {
      "data": {
        "id": "DTN",
        "type": "measurement_unit"
      }
    },
    "measurement_unit_qualifier": {
      "data": {
        "id": "E",
        "type": "measurement_unit_qualifier"
      }
    }
  }
}
```


### Units and measure conditions

Measure conditions may also use unit codes, and potentially also unit qualifiers, in order to set out a threshold, based on weight, volume or value.

For instance, at the point of writing, there is an allowance to export goods of a value of £10.00 or less of commodity code [Cigars, cheroots, cigarillos and cigarettes - 2402900000](https://www.trade-tariff.service.gov.uk/commodities/2402900000#export) to Belarus.

In this instance, we are looking at an export measure, with ID `20185322`. In a similar way to which we looked at the unit associated with measure components for duty purposes, we can also see that there are units on measure conditions which influence the trade.

In this instance, the unit is captured in the one of two nodes wihtin the measure_condition object associated with the measure (condition ID `20194642`):

The unit may be expressed either:

- in the `condition_measurement_unit_code` field (for weight / volume thresholds), *or*
- in the `condition_monetary_unit_code` field (for price thresholds)

```json
{
  "id": "20194642",
  "type": "measure_condition",
  "attributes": {
    "action": "Import/export allowed after control",
    "action_code": "29",
    "certificate_description": null,
    "condition": "E: The quantity or the price per unit declared, as appropriate, is equal or less than the specified maximum, or presentation of the required document",
    "condition_code": "E",
    "condition_duty_amount": 10,
    "condition_measurement_unit_code": null,
    "condition_measurement_unit_qualifier_code": null,
    "condition_monetary_unit_code": "GBP",
    "document_code": "",
    "duty_expression": "",
    "guidance_cds": null,
    "measure_condition_class": "threshold",
    "monetary_unit_abbreviation": null,
    "requirement": "<span>10.00</span> GBP",
    "requirement_operator": "=<",
    "threshold_unit_type": "price"
  },
  "relationships": {
    "measure_condition_components": {
      "data": []
    }
  }
}
```

For an example of a weight-based threshold, see commodity code [Mixtures of fruit and nuts ... containing hazelnuts 0813509970](https://www.trade-tariff.service.gov.uk/commodities/0813509970), which features a weight-based threshold for imports from Turkey, as follows:

```json
{
  "id": "20084295",
  "type": "measure_condition",
  "attributes": {
    "action": "Import/export allowed after control",
    "action_code": "29",
    "certificate_description": null,
    "condition": "E: The quantity or the price per unit declared, as appropriate, is equal or less than the specified maximum, or presentation of the required document",
    "condition_code": "E",
    "condition_duty_amount": 30,
    "condition_measurement_unit_code": "KGM",
    "condition_measurement_unit_qualifier_code": null,
    "condition_monetary_unit_code": null,
    "document_code": "",
    "duty_expression": "",
    "guidance_cds": null,
    "measure_condition_class": "threshold",
    "monetary_unit_abbreviation": null,
    "requirement": "<span>30.00</span> <abbr title='Kilogram'>kg</abbr>",
    "requirement_operator": "=<",
    "threshold_unit_type": "weight"
  },
  "relationships": {
    "measure_condition_components": {
      "data": []
    }
  }
}
```

## Measure condition permutations

Measure conditions are used to identify where:

- document codes (such as licences, certificates, waivers or exceptions) are needed
- weight or volume thresholds are applicable.

For instance, the certificate identified by document code **N002** is needed to import [cherry tomatoes](https://www.trade-tariff.service.gov.uk/commodities/0702000007#uk_import_controls), as described in the measure of type 'HMI Conformity Certificate (fruit and veg) issued in UK'.

And importing [champagne](https://www.trade-tariff.service.gov.uk/commodities/2204101100) from Switzerland has a threshold measure on the 'Restriction on entry into free circulation' measure (i.e. if the volume of goods imported does not exceed 100 litres, then the licence is not required).

In most cases, understanding measure conditions is simple. In most cases, if multiple conditions are presented, then the trader must fulfil one of the conditions (i.e. it is an OR boolean relationship between the conditions).

However, in certain cases, it is more complex.

### Complex measures

The term 'complex measures' has been invented by the Trade Tariff team to refer to those measures where there may be a requirement for more than one condition to be fulfilled by the trader (for example both the provision of a document and a threshold limit).

These 'complex measures' are most frequently present on:

- veterinary controls
- waste controls

Also look out for 'Import control of fluorinated greenhouse gases', as these measures exhibit a similar 'boolean AND' relationship, albeit in a different way.

To start with, let's look at veterinary controls.

#### Veterinary controls

Let's look at [rock lobsters, for processing](https://www.trade-tariff.service.gov.uk/commodities/0306111010) as an example. If you were to put across the import requirement (for vet control) in plain language, then you would write something like:

You need either:

- to provide a CHED-P document, as represented by document code N853, *or*
- to be exempted from this requirement via the provision of document code C084, to identify that you are bringing the goods into the country for scientific or research purposes, *or*
- you are bringing the goods in for personal consumption, *AND* the weight does not exceed 2 kilogrammes.

The AND in the last bullet is the complex part of this set of conditions.

#### Condition codes

The JSON code below is derived from the [API response for commodity code 0306111010](https://www.trade-tariff.service.gov.uk/api/v2/commodities/0306910000).


```json
{
      "id": "20243936",
      "type": "measure_condition",
      "attributes": {
        "action": "Import/export allowed after control",
        "action_code": "29",
        "certificate_description": "UN/EDIFACT certificates: ...",
        "condition_code": "B",
        "condition_duty_amount": null,
        "condition_measurement_unit_code": null,
        "condition_measurement_unit_qualifier_code": null,
        "condition_monetary_unit_code": null,
        "document_code": "N853",
        "duty_expression": "",
        "guidance_cds": "...",
        "measure_condition_class": "document",
        "monetary_unit_abbreviation": null,
        "requirement": "UN/EDIFACT certificates: UN/EDIFACT certificates: Common Health Entry Document ...",
        "requirement_operator": null,
        "threshold_unit_type": null
      },
      "relationships": {
        "measure_condition_components": {
          "data": []
        }
      }
    },
```

Crucial to the interpretation of this data is the **condition code**. The condition code, at a high level, describes to border systems (such as CDS) what the overarching condition means (e.g. a requirement for a licence, certificate or other document).

How the condition codes interact with others on conditions on the same measure determines the boolean logic to be applied.

These two rules are used to interpret the condition codes and their impact:

1. All **conditions with the same condition code** exist in a boolean **OR** relationship. i.e. the trader ust fulfil one of the requirements.

2. If a measure features conditions with **more than one condition code**, then a boolean **AND** relationship exists between the conditions assigned to the one condition code, and those assigned to the other (or others in the case of fluorinated gases).

The tables below show the 10 conditions that are associated with the veterinary control measure on the rock lobster commodity. As you can see, there are two condition codes, B and E (in the first column).

|Condition_code|Certificate type code|Certificate code|Action code|Condition duty amount|Condition measurement unit code|Notes|
|:----|:----|:----|:----|:----|:----|:----|
|**B**|N|853|29| | |CHED-P document|
|**B**|Y|058|29| | |Personal use waiver|
|**B**|C|084|29| | |Scientific use waiver|
|**B**|9|99L|29| | |CDS Licence waiver|
|**B**| | |09| | |Negative condition - prevent trade|

|Condition_code|Certificate type code|Certificate code|Action code|Condition duty amount|Condition measurement unit code|Notes|
|:----|:----|:----|:----|:----|:----|:----|
|**E**|N|853|29| | |CHED-P document|
|**E**| | |29|2.0|KGM|Threshold condition - do not exceed 2.0 KGM|
|**E**|C|084|29| | |Scientific use waiver|
|**E**|9|99L|29| | |CDS Licence waiver|
|**E**| | |09| | |Negative condition - prevent trade|

In the two tables above, you can see that:

- **N853** (CHED-P) is in both tables
- **C084** (scientific use waiver) is in both tables
- **999L** (CDS licence waiver) is in both tables

But

- the **threshold condition** is present only once
- **Y058** (personal use waiver) is present only once


The table below shows you how to interpret measures where:

- there are multiple measure condition codes, *and*
-  one or more of the conditions is repeated between the conditions of the different condition code types (see fluorinated gas example below, for when conditions are *not* repeated).

The idea is that, due to this 'AND' requirement, the trader picks one condition from the horizontal access

| |N853|C084|999L|Y058|
|:----|:----|:----|:----|:----|
|**N853**|**Duplicated**|Not relevant|Not relevant|Not relevant|
|**C084**|Not relevant|**Duplicated**|Not relevant|Not relevant|
|**999L**|Not relevant|Not relevant|**Duplicated**|Not relevant|
|**2.0 KGM**|Not relevant|Not relevant|Not relevant|**Boolean AND applies**|

The three discrete entries in the table are:

- **Duplicated** - as the same condition exists on both axes.
- **Not relevant** - while these are valid permutations, they are superseded by the supply of N853, C084 or 999L on their own.
- **Boolean AND applies** - this is a unique and discrete condition, and means that a trade can proceed if the goods are for personal consumption (Y058) and do not exceed a weight of 2 kilogrammes.

#### How we reflect this in 'permutations'

All measure conditions are listed in the 'included' section of the commodity API. However, this does not always tell the full tale of how they associate with each other, especially when it comes to complex measures such as the vet controls (or waster controls which behave similarly).

There are two primary entities (on top of the already mentioned measures and measure conditions) to recognise:

- measure_condition_permutation_group
- measure_condition_permutation

#### Measure condition permutation groups

The JSON block below shows the permutation group associated with rock lobster's vet control. You can see that there are four permutations that are related to the group. These four correspond to:

- The N853 document
- The C084 exemption
- The 999L waiver
- The threshold condition and the Y058 exemption

As these are pseudo-entities which do not exist in source data, we have created GUIDs for these. The actual GUID values do not matter: what matters is relating the parent permutation group with the individual permutations.

```json
{
  "id": "20200262-n/a",
  "type": "measure_condition_permutation_group",
  "attributes": {
    "condition_code": "n/a"
  },
  "relationships": {
    "permutations": {
      "data": [
        {
          "id": "6234c2e9dcb5f9dda1fd8cd62ea06e47",
          "type": "measure_condition_permutation"
        },
        {
          "id": "037195f93b2a0f7546dc9ac29445086e",
          "type": "measure_condition_permutation"
        },
        {
          "id": "9f91c1e665b90afca40ca5bcda62ddad",
          "type": "measure_condition_permutation"
        },
        {
          "id": "8c74355c5718a7e39d248a2825243881",
          "type": "measure_condition_permutation"
        }
      ]
    }
  }
}
```

#### Measure condition permutations

The block below just shows two of the permutations in the vet control above:

- a reference to the N853 (CHED-P) control
- a reference to the combined requirement (boolean AND) for a Y058 exemption and the 2.0 KGM threshold.

The second of the two permutation references two separate conditions to show that there is an AND relationship in place on this permutation.

```json
{
  "id": "6234c2e9dcb5f9dda1fd8cd62ea06e47",
  "type": "measure_condition_permutation",
  "relationships": {
    "measure_conditions": {
      "data": [
        {
          "id": "20243936",
          "type": "measure_condition"
        }
      ]
    }
  }
},
{
  "id": "8c74355c5718a7e39d248a2825243881",
  "type": "measure_condition_permutation",
  "relationships": {
    "measure_conditions": {
      "data": [
        {
          "id": "20243938",
          "type": "measure_condition"
        },
        {
          "id": "20243942",
          "type": "measure_condition"
        }
      ]
    }
  }
}
```

Measures of this type **can only ever have conditions with 2 discrete condition codes**. Otherwise the logic described here would not work.

### Complex measures where no conditions are repeated (Import control of fluorinated greenhouse gases)

The same rules regarding condition codes apply to other measure types, where conditions are not duplicated across condition code boundaries.

Measures of type 'Import control of fluorinated greenhouse gases' are the best example of these types of measure.

See the relevant control on [Refrigerated showcases, precharged with HFCs](https://www.trade-tariff.service.gov.uk/commodities/8418501910).

This type is simpler to understand than the very complex measures such as veterinary controls, as described previously, however the dual rules of condition codes still apply and need to be observed:

1. All **conditions with the same condition code** exist in a boolean **OR** relationship. i.e. the trader must fulfil one of the requirements (but is not required to fulfil more than one).

2. If a measure features conditions with **more than one condition code**, then a boolean **AND** relationship exists between the conditions assigned to the one condition code, and those assigned to the other (or others in the case of fluorinated gases).

In this instance, there are conditions with three different condition codes. The conditions are laid out on the condition popup in the way in which they are to be interpreted.

Pick:

- one option from the top table, *and*
- one option from the second table, *and*
- one option from the third table


## An overall approach to parsing the API

If you need to do anything more than just one single task on a commodity API, it's worth capturing and parsing every entity in the `included` section.

As the JSON:API convention includes referenced entities only once, it may be a more efficient approach to:

- parse the whole API response
- store entities in objects of bespoke classes
- build relationships between the entities, according to the relationships expressed in the API response.

## Feedback on this documentation

We would love to hear what you think of this page. If you have any feedback, queries or issues, please contact the team on [hmrc-trade-tariff-support-g@digital.hmrc.gov.uk](mailto:hmrc-trade-tariff-support-g@digital.hmrc.gov.uk).
