import { landingContent } from '../../lib/landing-content'
import { SectionTitle } from './section-title'

export function AboutSection() {
  const { about } = landingContent

  return (
    <section className="aboutSection" aria-labelledby="about-title">
      <SectionTitle className="aboutTitle">
        <span id="about-title">{about.title}</span>
      </SectionTitle>
      <p className="aboutText">{about.text}</p>
      <img className="aboutImage" src={about.imageSrc} alt={about.imageAlt} />
    </section>
  )
}
