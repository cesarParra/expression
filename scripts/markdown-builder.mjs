import yaml from 'js-yaml';

export default class MarkdownBuilder {
  constructor() {
    this.markdown = '';
  }

  frontMatter(frontMatter) {
    this.markdown += `---\n${yaml.dump(frontMatter)}---\n`;
    this.markdown += '\n';
  }

  h1(text) {
    this.markdown += `# ${text}\n`;
    this.markdown += '\n';
  }

  h2(text) {
    this.markdown += `## ${text}\n`;
    this.markdown += '\n';
  }

  h3(text) {
    this.markdown += `### ${text}\n`;
    this.markdown += '\n';
  }

  text(text) {
    const sanitizedText = text.replace(/<br\/>/g, '\n');
    this.markdown += `${sanitizedText}\n`;
    this.markdown += '\n';
  }

  code(text) {
    this.markdown += `\`\`\`\n${text}\n\`\`\`\n`;
    this.markdown += '\n';
  }

  list(items) {
    this.markdown += items.map((item) => `- ${item}\n`).join('');
  }
}
