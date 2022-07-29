#!/usr/bin/env node

const fs = require('fs');
const yaml = require('js-yaml');
const converter = require('widdershins');
const inputFile = fs.readFileSync(process.argv[2], 'utf8');
const api = yaml.safeLoad(inputFile, {json: true});

function appendSchemaDescription(data) {
  const schemas = data.openapi.components.schemas;

  for (name in schemas) {
    const schema = schemas[name];
    if (schema.example != data.schema || !schema.description) {
      continue;
    }

    data.append = schema.description + '\n\n';
  }
}

const options = {
  codeSamples: true,
  language_tabs: [
    {'shell': 'Shell'},
  ],
  user_templates: 'templates',
  sample: true,
  templateCallback: function(templateName, stage, data) {
    if (templateName == 'schema_sample' && stage == 'pre') {
      appendSchemaDescription(data);
    }
    return data;
  },
  omitHeader: true,
};


converter.convert(api, options, function(_err, output) {
  fs.writeFileSync(process.argv[3], output, 'utf8');
});
