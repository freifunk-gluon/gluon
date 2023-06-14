import { h, render } from "preact";
/* import App from "./App";

render(<App />, document.getElementById("root")!); */

import GluonWeb2 from "./GluonWeb2";

const INSTANCES: Record<string, GluonWeb2Instance> = {}

class GluonWeb2Instance {
  readonly el: HTMLElement;
  readonly rendered: any;

  constructor(el: HTMLElement) {
    this.el = el;
    const dataset = this.el.dataset

    try {
      let parsedData = JSON.parse(atob(dataset.componentData))

      this.rendered = render(<GluonWeb2
        id={dataset.gluonWeb2}
        component={dataset.component}
        data={parsedData}
      />, this.el)
    } catch (error) {
      const errEl = document.createElement('p')
      errEl.classList.add('web2-error')
      el.appendChild(errEl)
      errEl.appendChild(document.createTextNode(
        JSON.stringify(dataset, null, 2) + ' ' + String(error)
      ))
    }
  }

  teardown() {

  }
}

function findGluonWeb2() {
  const nodes = document.querySelectorAll('gluon-web2')

  let seen: Record<string, boolean> = {}

  for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i] as HTMLElement

    if (!node.dataset.gluonWeb2) {
      node.dataset.gluonWeb2 = String(Math.random())
      INSTANCES[node.dataset.gluonWeb2] = new GluonWeb2Instance(node)
    }

    seen[node.dataset.gluonWeb2] = true
  }

  for (const key of Object.keys(INSTANCES).filter(k => !seen[k])) {
    INSTANCES[key].teardown()
    delete INSTANCES[key]
  }
}

window.GluonWeb2Refresh = findGluonWeb2

findGluonWeb2()
