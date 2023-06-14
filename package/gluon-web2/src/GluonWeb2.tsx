import { Fragment, h } from "preact";
import { useState } from 'preact/hooks';

import Components from "./components"

const GluonWeb2 = ({ id, component, data: initialData }: { id: string, component: string, data: any }) => {
  const { data, setData } = useState<any>(initialData)

  return (
    <Fragment>
      <input type="text" style="display: none" name={id} value={JSON.stringify(data)} />,
      {
        h(Components[component], {
          data,
          setData
        })
      }
    </Fragment>
  )
}

export default GluonWeb2;
