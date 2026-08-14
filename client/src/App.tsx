// Style philosophy: مختبر المعرفة المعاصر — routes stay few, purposeful, and easy to escape.
import { Route, Switch } from "wouter";
import ErrorBoundary from "./components/ErrorBoundary";
import { ThemeProvider } from "./contexts/ThemeContext";
import Home from "./pages/Home";
import Play from "./pages/Play";
import Adventure from "./pages/Adventure";

function App() {
  return <ErrorBoundary><ThemeProvider defaultTheme="dark"><Switch><Route path="/" component={Home} /><Route path="/play" component={Play} /><Route path="/adventure" component={Adventure} /><Route component={Home} /></Switch></ThemeProvider></ErrorBoundary>;
}

export default App;
