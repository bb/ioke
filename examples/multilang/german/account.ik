use("german")

Konto = Ursprung imitator mache(
  überweise = methode(betrag, von: selbst, zu:,
    von kontostand -= betrag
    zu kontostand += betrag
  )

  drucke = methode(
    "<Konto name: #{name} kontostand: #{kontostand}>" druckeZeile
  )
)

Hans = Konto mit(name: "Hans", kontostand: 142.0)
Franz = Konto mit(name: "Franz", kontostand: 45.7)

Konto überweise(23.0, von: Hans, zu: Franz)
Konto überweise(10.0, zu: Hans, von: Franz)
Franz überweise(57.4, zu: Hans)

Hans  drucke
Franz drucke
