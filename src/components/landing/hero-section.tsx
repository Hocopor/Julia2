import { landingContent, links } from '../../lib/landing-content'
import { BurgerIcon } from './burger-icon'
import { CTAButton } from './cta-button'

export function HeroSection() {
  const { hero } = landingContent

  return (
    <section className="heroSection" aria-label="Первый экран">
      <div className="heroTopbar">
        <p className="heroRole">{hero.role}</p>
        <BurgerIcon />
      </div>
      <h1 className="heroName">
        <span>{hero.firstName}</span>
        <span>{hero.lastName}</span>
      </h1>
      <div className="heroImageWrap">
        <img className="heroImage" src={hero.imageSrc} alt={hero.imageAlt} />
        <div className="quoteCard">
          <p className="quoteCardText">
            ПОМОГУ РАЗРЕШИТЬ ВНУТРЕННИЕ КОНФЛИКТЫ,{' '}
            <strong className="quoteCardAccent">
              <em>РАЗОБРАТЬСЯ В СЕБЕ И СВОИХ ЧУВСТВАХ</em>
            </strong>
            , И ПРИБЛИЗИТЬСЯ К НАСТОЯЩЕМУ СПОКОЙСТВИЮ.
          </p>
        </div>
      </div>
      <CTAButton href={links.cta} label={hero.ctaLabel} />
    </section>
  )
}
