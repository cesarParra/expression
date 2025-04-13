import getFunctions from '@salesforce/apex/PlaygroundController.getCustomFunctions';
import {operators} from './operators';
import {data} from './functions-src';

export async function getFunctionsAndOperators() {
  const dbFunctions = await getDbFunctions();
  const categories = dbFunctions
    .filter((category) => category.functions.length)
    .map((category) => {
      return {
        category: category.name,
        values: category.functions.map((fn) => {
          return {
            name: fn.name,
            autoCompleteValue: fn.autoCompleteValue,
            icon: category.icon,
            description: fn.description,
            examples: fn.example ? [fn.example] : undefined
          };
        })
      };
    });

  return [...operators, ...data, ...categories];
}

async function getDbFunctions() {
  try {
    const dbFunctions = await getFunctions();
    return dbFunctions;
  } catch (error) {
    return [];
  }
}
