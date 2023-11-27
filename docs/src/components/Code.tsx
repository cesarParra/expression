'use client'

import * as Prism from 'prismjs';

import * as React from 'react';
import copy from 'copy-to-clipboard';

import {Icon} from './CopyIcon';

Prism.languages.markdoc = {
    tag: {
        pattern: /{%(.|\n)*?%}/i,
        inside: {
            tagType: {
                pattern: /^({%\s*\/?)(\w|-)*\b/i,
                lookbehind: true
            },
            id: /#(\w|-)*\b/,
            string: /".*?"/,
            equals: /=/,
            number: /\b\d+\b/i,
            variable: {
                pattern: /\$[\w.]+/i,
                inside: {
                    punctuation: /\./i
                }
            },
            function: /\b\w+(?=\()/,
            punctuation: /({%|\/?%})/i,
            boolean: /false|true/
        }
    },
    variable: {
        pattern: /\$\w+/i
    },
    function: {
        pattern: /\b\w+(?=\()/i
    }
};

var keywords = /\b(?:(?:after|before)(?=\s+[a-z])|abstract|activate|and|any|array|as|asc|autonomous|begin|bigdecimal|blob|boolean|break|bulk|by|byte|case|cast|catch|char|class|collect|commit|const|continue|currency|date|datetime|decimal|default|delete|desc|do|double|else|end|enum|exception|exit|export|extends|final|finally|float|for|from|get(?=\s*[{};])|global|goto|group|having|hint|if|implements|import|in|inner|insert|instanceof|int|integer|interface|into|join|like|limit|list|long|loop|map|merge|new|not|null|nulls|number|object|of|on|or|outer|override|package|parallel|pragma|private|protected|public|retrieve|return|rollback|select|set|short|sObject|sort|static|string|super|switch|synchronized|system|testmethod|then|this|throw|time|transaction|transient|trigger|try|undelete|update|upsert|using|virtual|void|webservice|when|where|while|(?:inherited|with|without)\s+sharing)\b/i;

var className = /\b(?:(?=[a-z_]\w*\s*[<\[])|(?!<keyword>))[A-Z_]\w*(?:\s*\.\s*[A-Z_]\w*)*\b(?:\s*(?:\[\s*\]|<(?:[^<>]|<(?:[^<>]|<[^<>]*>)*>)*>))*/.source
    .replace(/<keyword>/g, function () {
        return keywords.source;
    });

/** @param {string} pattern */
function insertClassName(pattern: string) {
    return RegExp(pattern.replace(/<CLASS-NAME>/g, function () {
        return className;
    }), 'i');
}

var classNameInside = {
    'keyword': keywords,
    'punctuation': /[()\[\]{};,:.<>]/
};

Prism.languages.apex = {
    'comment': Prism.languages.clike.comment,
    'string': Prism.languages.clike.string,
    'sql': {
        pattern: /((?:[=,({:]|\breturn)\s*)\[[^\[\]]*\]/i,
        lookbehind: true,
        greedy: true,
        alias: 'language-sql',
        inside: Prism.languages.sql
    },

    'annotation': {
        pattern: /@\w+\b/,
        alias: 'punctuation'
    },
    'class-name': [
        {
            pattern: insertClassName(/(\b(?:class|enum|extends|implements|instanceof|interface|new|trigger\s+\w+\s+on)\s+)<CLASS-NAME>/.source),
            lookbehind: true,
            inside: classNameInside
        },
        {
            // cast
            pattern: insertClassName(/(\(\s*)<CLASS-NAME>(?=\s*\)\s*[\w(])/.source),
            lookbehind: true,
            inside: classNameInside
        },
        {
            // variable/parameter declaration and return types
            pattern: insertClassName(/<CLASS-NAME>(?=\s*\w+\s*[;=,(){:])/.source),
            inside: classNameInside
        }
    ],
    'trigger': {
        pattern: /(\btrigger\s+)\w+\b/i,
        lookbehind: true,
        alias: 'class-name'
    },
    'keyword': keywords,
    'function': /\b[a-z_]\w*(?=\s*\()/i,

    'boolean': /\b(?:false|true)\b/i,

    'number': /(?:\B\.\d+|\b\d+(?:\.\d+|L)?)\b/i,
    'operator': /[!=](?:==?)?|\?\.?|&&|\|\||--|\+\+|[-+*/^&|]=?|:|<<?=?|>{1,3}=?/,
    'punctuation': /[()\[\]{};,.]/
};

// @ts-ignore
export function Code({children, 'data-language': language}) {
    const [copied, setCopied] = React.useState(false);
    const ref = React.useRef(null);

    React.useEffect(() => {
        if (ref.current) Prism.highlightElement(ref.current, false);
    }, [children]);

    React.useEffect(() => {
        if (copied) {
            // @ts-ignore
            copy(ref.current.innerText);
            const to = setTimeout(setCopied, 1000, false);
            return () => clearTimeout(to);
        }
    }, [copied]);

    const lang = language === 'md' ? 'markdoc' : language || 'markdoc';

    const lines =
        typeof children === 'string' ? children.split('\n').filter(Boolean) : [];

    // @ts-ignore
    return (
        <div className="code" aria-live="polite">
      <pre
          // Prevents "Failed to execute 'removeChild' on 'Node'" error
          // https://stackoverflow.com/questions/54880669/react-domexception-failed-to-execute-removechild-on-node-the-node-to-be-re
          key={children}
          ref={ref}
          className={`language-${lang}`}
      >
        {children}
      </pre>
            <button onClick={() => setCopied(true)}>
                <Icon icon={copied ? 'copied' : 'copy'}/>
            </button>
            <style jsx>
                {`
                  .code {
                    position: relative;
                  }

                  .code button {
                    appearance: none;
                    position: absolute;
                    color: inherit;
                    background: var(--code-background);
                    top: ${lines.length === 1 ? '17px' : '13px'};
                    right: 11px;
                    border-radius: 4px;
                    border: none;
                    font-size: 15px;
                  }
                `}
            </style>
        </div>
    );
}
