// Style philosophy: مختبر المعرفة المعاصر — routes stay few, purposeful, and easy to escape.
import { lazy, Suspense } from "react";
import { Route, Switch } from "wouter";
import ErrorBoundary from "./components/ErrorBoundary";
import { ThemeProvider } from "./contexts/ThemeContext";

const Home = lazy(() => import("./pages/Home"));
const Play = lazy(() => import("./pages/Play"));
const Adventure = lazy(() => import("./pages/Adventure"));
const Profile = lazy(() => import("./pages/Profile"));
const Community = lazy(() => import("./pages/Community"));
const Arcade = lazy(() => import("./pages/Arcade"));
const Shop = lazy(() => import("./pages/Shop"));
const OwnerConsole = lazy(() => import("./pages/OwnerConsole"));
const ArchitectConsole = lazy(() => import("./pages/ArchitectConsole"));

function App() {
  return <ErrorBoundary><ThemeProvider defaultTheme="dark"><Suspense fallback={<div className="route-loader">تهيئة مسار Nexus…</div>}><Switch><Route path="/" component={Home} /><Route path="/play" component={Play} /><Route path="/adventure" component={Adventure} /><Route path="/profile" component={Profile} /><Route path="/community" component={Community} /><Route path="/arcade" component={Arcade} /><Route path="/shop" component={Shop} /><Route path="/owner" component={OwnerConsole} /><Route path="/architect" component={ArchitectConsole} /><Route component={Home} /></Switch></Suspense></ThemeProvider></ErrorBoundary>;
}

export default App;
