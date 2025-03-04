const {syntaxTree, linter} = SupportedCells.codemirror.context;

const regexpLinter = linter(async view => {
  let check_list = []

  syntaxTree(view.state).cursor().iterate(node => {
    console.log(node.name);

    switch(node.name) {
      case 'ATXHeading1':
      case 'ATXHeading2':
      case 'ATXHeading3':
      case 'ATXHeading4':
      case 'Paragraph':
      case 'Emphasis':
      case 'StrongEmphasis':
        check_list.push([node.from+1, node.to]);
      break;

      default:
    }
  });

  //console.warn(check_list);
  let results = await server.io.request('spellcheck-extension', [check_list, view.dom.ocellref.origin.uid], 'Check');
  results = await interpretate(results, {});

  //console.warn(results);

  if (!results) return [];
  if (!Array.isArray(results)) return [];

  const n = results.map((node) => {
    console.warn(node);
    const {to, from, item} = node;
    return {
        from: from-2,
        to: to-1,
        severity: "warning",
        message: "Spelling",
        actions: item.map((i) => {return {
            name: i,
            apply(view, from, to) { view.dispatch({changes: {from: from, to: to, insert: i}}) }
        }})
    }    
    });

    return n;
})

SupportedLanguages.filter((el) => el.name == 'markdown').forEach((element) => {
    element.plugins.push(regexpLinter);
})