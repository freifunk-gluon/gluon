import { render, h } from "preact";
import App from "./App";

it("renders without crashing", () => {
  const div = document.createElement("div");
  render(<App />, div);
  render(null, div);
});
