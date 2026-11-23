#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const WORDS = {
  'overused verb': 'delve leverage utilise utilize facilitate foster bolster underscore unveil streamline endeavour endeavor ascertain elucidate'.split(' '),
  'overused adjective': 'robust comprehensive pivotal crucial vital transformative cutting-edge groundbreaking innovative seamless intricate nuanced multifaceted holistic'.split(' '),
  'filler': 'absolutely actually basically certainly clearly definitely essentially extremely fundamentally incredibly interestingly naturally obviously quite really significantly surely truly ultimately undoubtedly very'.split(' '),
  'empowerment verb': 'empowering unlocking enabling transforming elevating revolutionizing supercharge'.split(' '),
};
const PHRASES = {
  'antithesis': ['not just', 'not only', 'instead of', 'rather than'],
  'academic tell': ['shed light on', 'pave the way', 'a myriad of', 'a plethora of', 'pertaining to', 'prior to', 'in light of', 'with respect to', 'in terms of', 'the fact that'],
  'scene-setting opener': ["in today's", 'in an era of', 'in the realm of', 'in the landscape of', 'in the ever-evolving'],
  'pose': ['in the room', 'end to end', 'high-impact', 'best-in-class', 'world-class', 'so you can focus on what matters'],
  'transition': ['furthermore', 'moreover', 'that being said', 'at its core', 'to put it simply', 'it is worth noting'],
};

const ALLOWED = new Set();
const houseWordsPath = path.join(path.dirname(fileURLToPath(import.meta.url)), 'house-words.json');
if (fs.existsSync(houseWordsPath)) {
  const house = JSON.parse(fs.readFileSync(houseWordsPath, 'utf8'));
  Object.assign(WORDS, house.words);
  Object.assign(PHRASES, house.phrases);
  for (const entry of house.allow ?? []) ALLOWED.add(entry);
  for (const lists of [WORDS, PHRASES])
    for (const kind of Object.keys(lists))
      lists[kind] = lists[kind].filter((entry) => !ALLOWED.has(entry));
}

const escapeForPattern = (word) => word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const strip = (text) => text
  .replace(/<(style|script)[\s\S]*?<\/\1>/gi, ' ')
  .replace(/<[^>]+>/g, ' ')
  .replace(/```[\s\S]*?```/g, ' ')
  .replace(/`[^`]*`/g, ' ')
  .replace(/"[^"]{0,300}"/g, ' ')
  .replace(/https?:\/\/\S+/g, ' ');

const wordCount = (sentence) => sentence.split(/\s+/).length;
const sentencesIn = (text) => text.split(/(?<=[.!?])\s+/).map((sentence) => sentence.trim()).filter(Boolean);

const PARAGRAPH_BREAK = /\n\s*\n|<\/(?:p|li|dd|h[1-6])>/i;
const LIST_TABLE_OR_HEADING = /^(\||[-*#>]|\d+\.|\{\{)/;
const MOST_SENTENCES_IN_A_PARAGRAPH = 3;
const LONG_WORD = /\b[a-z]{13,}\b/g;

function longParagraphs(raw) {
  return raw
    .replace(/```[\s\S]*?```/g, ' ')
    .split(PARAGRAPH_BREAK)
    .map((block) => block.trim())
    .filter((block) => !LIST_TABLE_OR_HEADING.test(block))
    .map((block) => strip(block).replace(/\s+/g, ' ').trim())
    .filter((paragraph) => sentencesIn(paragraph).length > MOST_SENTENCES_IN_A_PARAGRAPH);
}

function check(name, raw) {
  const text = strip(raw);
  const lowered = text.toLowerCase();
  const findings = [];
  const review = [];

  for (const [kind, list] of Object.entries(WORDS))
    for (const word of list)
      if (new RegExp(`\\b${escapeForPattern(word)}\\b`, 'i').test(lowered)) findings.push([kind, word]);
  for (const [kind, list] of Object.entries(PHRASES))
    for (const phrase of list)
      if (lowered.includes(phrase.toLowerCase())) findings.push([kind, phrase]);

  if (/—/.test(text)) findings.push(['em dash', '—']);
  if (/\s--\s/.test(text)) findings.push(['double hyphen', '--']);

  const sentences = sentencesIn(text);
  const lengths = sentences.map(wordCount).sort((shorter, longer) => shorter - longer);

  for (let index = 1; index < sentences.length; index++) {
    const previousLength = wordCount(sentences[index - 1]);
    const currentLength = wordCount(sentences[index]);
    if (currentLength <= 8 && previousLength >= 14) review.push(['possible stub, advancing or decorating?', sentences[index]]);
  }

  for (const paragraph of longParagraphs(raw))
    review.push([`paragraph of ${sentencesIn(paragraph).length} sentences, split where the subject changes`, `${paragraph.slice(0, 70)}...`]);

  const longWords = [...new Set(text.match(LONG_WORD))].filter((word) => !ALLOWED.has(word));
  if (longWords.length) review.push(['long words, does a shorter one mean the same?', longWords.join(', ')]);

  console.log(`\n${name}`);
  if (!findings.length && !review.length) console.log('  clean');
  for (const [kind, hit] of findings) console.log(`  FAIL   [${kind}] ${hit}`);
  for (const [kind, hit] of review) console.log(`  review [${kind}] ${hit}`);
  if (lengths.length > 2) {
    const median = lengths[Math.floor(lengths.length / 2)];
    const shortest = lengths[0];
    const longest = lengths[lengths.length - 1];
    const uniform = lengths.length > 5 && longest - shortest < 8;
    console.log(`  sentence lengths: min ${shortest}, median ${median}, max ${longest}${uniform ? '  <-- too uniform, vary them' : ''}`);
  }
  return findings.length;
}

const files = process.argv.slice(2);
let total = 0;
if (files.length) for (const file of files) total += check(file, fs.readFileSync(file, 'utf8'));
else total += check('(stdin)', fs.readFileSync(0, 'utf8'));
console.log(`\n${total} failure(s). Review lines are judgment calls, not errors.`);
process.exit(total ? 1 : 0);
