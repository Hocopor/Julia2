import { AboutSection } from './about-section'
import { ContactsSection } from './contacts-section'
import { HeroSection } from './hero-section'
import { IssuesSection } from './issues-section'
import { PricingSection } from './pricing-section'

export function LandingPage() {
  return (
    <main>
      <div className="pageBg">
        <div className="landingShell">
          <HeroSection />
          <AboutSection />
          <IssuesSection />
          <PricingSection />
          <ContactsSection />
        </div>
      </div>
    </main>
  )
}
