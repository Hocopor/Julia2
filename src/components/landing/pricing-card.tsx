import { links } from '../../lib/landing-content'
import { CTAButton } from './cta-button'

interface PricingRow {
  label: string
  value: string
}

interface PricingCardProps {
  number: string
  title: string
  rows: readonly PricingRow[]
  ctaLabel: string
}

export function PricingCard({ number, title, rows, ctaLabel }: PricingCardProps) {
  return (
    <article className="pricingCard">
      <div className="pricingCardHeader">
        <span className="pricingCardNumber">{number}</span>
        <h3 className="pricingCardTitle">{title}</h3>
      </div>
      <div className="pricingRows">
        {rows.map((row) => (
          <div className="pricingMetaRow" key={`${title}-${row.label}`}>
            <span className="pricingMetaLabel">{row.label}</span>
            <span className="pricingMetaValue">{row.value}</span>
          </div>
        ))}
      </div>
      <CTAButton href={links.cta} label={ctaLabel} />
    </article>
  )
}
