import { describe, expect, it } from "vitest";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join, relative } from "node:path";
import ts from "typescript";

const FRONTEND_ROOT = join(__dirname, "..");
const REPOSITORY_ROOT = join(FRONTEND_ROOT, "..");
const CODE_ROOTS = [FRONTEND_ROOT, join(REPOSITORY_ROOT, "e2e"), join(REPOSITORY_ROOT, "tools")];
const GENERATED_DIRECTORIES = new Set([
  "node_modules",
  "build",
  "dist",
  ".react-router",
  "playwright-report",
  "test-results",
  "vendor",
  ".vite",
]);
const CODE_FILE = /\.(tsx?|jsx?|mjs|cjs)$/;
const MINIFIED_FILE = /\.min\./;
const TOOL_DIRECTIVE =
  /^(\/\/\s*(eslint-|@ts-expect-error|@ts-ignore|@ts-nocheck|prettier-ignore|istanbul|v8 ignore|c8 ignore|@vitest-environment)|\/\/\/\s*<reference|\/\*\s*(@vite-ignore|eslint-|istanbul|v8 ignore|c8 ignore|global |globals |@jsxImportSource|webpack|#__PURE__|@__PURE__)|\/\*\*\s*@(type|vitest-environment|jest-environment)|#!)/;

function codeFilesUnder(directory: string): string[] {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    if (GENERATED_DIRECTORIES.has(entry.name)) return [];
    const entryPath = join(directory, entry.name);
    if (entry.isDirectory()) return codeFilesUnder(entryPath);
    return CODE_FILE.test(entry.name) && !MINIFIED_FILE.test(entry.name) ? [entryPath] : [];
  });
}

function scriptKindOf(filePath: string): ts.ScriptKind {
  if (filePath.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (filePath.endsWith(".jsx")) return ts.ScriptKind.JSX;
  if (filePath.endsWith(".ts")) return ts.ScriptKind.TS;
  return ts.ScriptKind.JS;
}

function commentsIn(filePath: string): string[] {
  const text = readFileSync(filePath, "utf8");
  const sourceFile = ts.createSourceFile(
    filePath,
    text,
    ts.ScriptTarget.Latest,
    true,
    scriptKindOf(filePath),
  );
  const commentByStart = new Map<number, string>();

  const recordRanges = (ranges: ts.CommentRange[] | undefined) => {
    for (const range of ranges ?? []) {
      const commentText = text.slice(range.pos, range.end);
      if (!TOOL_DIRECTIVE.test(commentText)) commentByStart.set(range.pos, commentText);
    }
  };

  const visit = (node: ts.Node) => {
    if (node.kind === ts.SyntaxKind.JsxText) return;
    if (ts.isJsxExpression(node) && !node.expression) {
      recordRanges(ts.getLeadingCommentRanges(text, node.getStart(sourceFile) + 1));
    }
    if (node.getChildCount(sourceFile) === 0) {
      recordRanges(ts.getLeadingCommentRanges(text, node.getFullStart()));
      recordRanges(ts.getTrailingCommentRanges(text, node.getEnd()));
    }
    node.getChildren(sourceFile).forEach(visit);
  };
  visit(sourceFile);

  const pathFromRoot = relative(REPOSITORY_ROOT, filePath);
  return [...commentByStart.entries()].map(([start, commentText]) => {
    const lineNumber = sourceFile.getLineAndCharacterOfPosition(start).line + 1;
    return `${pathFromRoot}:${lineNumber} ${commentText.replace(/\s+/g, " ")}`;
  });
}

describe("code carries no comments", () => {
  it("finds none in the frontend, the browser tests or the tools", () => {
    const codeFiles = CODE_ROOTS.filter((rootPath) => existsSync(rootPath)).flatMap(codeFilesUnder);

    expect(codeFiles.length).toBeGreaterThan(10);
    expect(codeFiles.flatMap(commentsIn)).toEqual([]);
  });
});
