import { landingContent } from '../../lib/landing-content'

export function ContactsSection() {
  const { contacts } = landingContent

  return (
    <section className="contactsSection" aria-labelledby="contacts-title" id="contact">
      <div className="contactsImageWrap">
        <img className="contactsImage" src={contacts.imageSrc} alt={contacts.imageAlt} />
        <h2 className="contactsTitle" id="contacts-title">
          {contacts.title}
        </h2>
      </div>
      <div className="contactsLinks" aria-label="Контактные ссылки">
        {contacts.items.map((item) => (
          <a
            className="contactsLink"
            href={item.href}
            key={item.label}
            target={item.href.startsWith('http') ? '_blank' : undefined}
            rel={item.href.startsWith('http') ? 'noreferrer' : undefined}
          >
            {item.label}
          </a>
        ))}
      </div>
    </section>
  )
}
