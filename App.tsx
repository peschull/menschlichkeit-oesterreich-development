import { Navigation } from './components/Navigation';
import { Hero } from './components/Hero';
import { About } from './components/About';
import { Themes } from './components/Themes';
import { Forum } from './components/Forum';
import { Join } from './components/Join';
import { Donate } from './components/Donate';
import { Events } from './components/Events';
import { News } from './components/News';
import { Contact } from './components/Contact';
import { Footer } from './components/Footer';

export default function App() {
  return (
    <div className="min-h-screen">
      {/* Skip to main content link for accessibility */}
      <a 
        href="#main-content" 
        className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 bg-primary text-primary-foreground px-4 py-2 rounded-md z-50"
      >
        Zum Hauptinhalt springen
      </a>

      <Navigation />
      
      <main id="main-content" className="relative">
        <Hero />
        <About />
        <Themes />
        <Forum />
        <Join />
        <Donate />
        <Events />
        <News />
        <Contact />
      </main>

      <Footer />
    </div>
  );
}