import { landingContent } from '../../lib/landing-content'
import { PricingCard } from './pricing-card'
import { SectionTitle } from './section-title'

export function PricingSection() {
  const { pricing } = landingContent

  return (
    <section className="pricingSection" aria-labelledby="pricing-title">
      <SectionTitle className="pricingTitle">
        <span id="pricing-title">{pricing.title}</span>
      </SectionTitle>
      <img className="pricingFlower" src={pricing.flowerImageSrc} alt={pricing.flowerImageAlt} />
      <div className="pricingStack">
        <PricingCard {...pricing.items[0]} />
        <img className="seaImage" src={pricing.seaImageSrc} alt={pricing.seaImageAlt} />
        <PricingCard {...pricing.items[1]} />
        <PricingCard {...pricing.items[2]} />
      </div>
      <div className="pricingNote" aria-label="Дополнительная информация">
        {pricing.note.map((part) => (
          <p key={part}>{part}</p>
        ))}
      </div>
    </section>
  )
}
