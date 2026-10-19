# MXOQ source-index prior art

Source: `heartpunk/mxoq` at commit `05e5273f90136de354d8dffe6491c66fa178dcb8`, [`imark.html` lines 3995–4032](https://github.com/heartpunk/mxoq/blob/05e5273f90136de354d8dffe6491c66fa178dcb8/imark.html#L3995-L4032). A live version is available [here](https://heartpunk.github.io/mxoq/imark.html). In the local checkout checked on 2026-10-16, both `main` and `origin/main` pointed to this commit.

The example builds a source index from the LTS function inventory: instruction PC to source location, source file to lines, and source file plus line to instruction PCs. The file key includes the directory-prefixed source path to avoid collisions between files with the same basename. This is the prior art referred to by the visualizer bullet.

## Source-index helper, from the pinned file

```js
// Index built once per LTS load: pc → SourceLoc-shape, source_file →
// {raw, comp_dir, lines: line→text}, (source_file, line) → list of
// instruction PCs that emit from that source line.
let _sourceIndex = null;
function _ensureSourceIndex() {
  if (_sourceIndex) return _sourceIndex;
  const fn = (lts && lts.function_index && lts.function_index[0]) || null;
  const idx = {
    pcToLoc: {},                 // pc-string → {source_file, source_line, ...}
    fileToLines: {},             // source_file → {raw, comp_dir, lines: {line: text}}
    fileLineToPcs: {},           // `${source_file}\u0001${line}` → [pc-string, ...]
  };
  if (!fn) { _sourceIndex = idx; return idx; }
  for (const ins of fn.instructions || []) {
    if (!ins.source_file || !ins.source_line) continue;
    idx.pcToLoc[ins.pc] = {
      source_file: ins.source_file,
      source_file_raw: ins.source_file_raw,
      source_comp_dir: ins.source_comp_dir,
      source_line: ins.source_line,
      source_column: ins.source_column || 0,
    };
    const key = ins.source_file + '\u0001' + ins.source_line;
    if (!idx.fileLineToPcs[key]) idx.fileLineToPcs[key] = [];
    idx.fileLineToPcs[key].push(ins.pc);
  }
  for (const f of fn.source_files || []) {
    const lineMap = {};
    for (const lobj of f.lines || []) lineMap[lobj.line] = lobj.text;
    idx.fileToLines[f.source_file] = {
      source_file_raw: f.source_file_raw,
      source_comp_dir: f.source_comp_dir,
      lines: lineMap,
    };
  }
  _sourceIndex = idx;
  return idx;
}
```
