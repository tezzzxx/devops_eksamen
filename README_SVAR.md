# README_SVAR – Pgr301 Eksamen 2026

Kandidatnummer: 14

## Oppgave 1

### 1A

    docker build -t wishifai .
    docker run -p 9999:8080 -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION=eu-west-1 wishifai

### 1B

Grønn kjøring: https://github.com/tezzzxx/devops_eksamen/actions/runs/42791613842

Imaget tagges med commit-SHA og latest. SHA-en gjør det mulig å spore hvilken commit som kjører, og det er den som deployes. Latest alene sier ikke hvilken versjon som kjører.

## Oppgave 2

### 2A

URL: https://wi-f448f2e17cd140338d36d041659adca5.ecs.eu-west-1.on.aws

### 2B

State-nøkkel: `wishifai/14/terraform.tfstate`

### 2C

Grønn kjøring: https://github.com/tezzzxx/devops_eksamen/actions/runs/43189075458

Terraform deployer imaget med den nye SHA-taggen. Hvis terraform kjøres før eller samtidig som den blir bygget, finnes ikke imaget i ecr. Feiler bygget, blir det heller ikke deployet noe.

## Oppgave 3

### 3A

"wishifai.rekognition.latency" (Timer): Måler hvor lang tid Rekognition-kallet tar.

"wishifai.bedrock.latency" (Timer): Måler hvor lang tid Bedrock-kallet tar.

"wishifai.suggestions.count" (DistributionSummary): Business-metrikk. Teller hvor mange gaveforslag hver analyse gir, og viser hvor mye tjenesten brukes.

Målingene viser at Bedrock bruker rundt 15–16 sekunder per kall, mens Rekognition bruker rundt 0,6 sekunder. Det er altså Bedrock som gjør tjenesten treg.

### 3B

Dashboard: `wishifai-14`

Screenshot ligger under "/devops_3b.png"

Dashbordet viser business, altså bilder analysert og gaveforslag. Applikasjon viser latens for Rekognition og Bedrock, JVM heap og HTTP-responstid fra Actuator. Infrastruktur viser CPU og minne for ECS-tjenesten.

Alarmen går hvis snittlatensen på Bedrock er over 30 sekunder i 3 minutter. Bedrock bruker normalt rundt 15 sekunder, så grensen er satt til det dobbelte for å fange opp unormal treghet.

## Oppgave 4

Da jeg i denne oppgaven sendte inn det samme stuebildet flere ganger for å teste at alt fungerte som det skulle, la jeg merke til dette. Rekognition presenterte meg med de samme objektene hver gang, samtidig som at bedrock ga med generelt forskjellige gaver. Kvaliteten på outputen jeg fikk var ikke det beste. På tross av dette så fikk jeg status 200. Teknisk fungerer løsningen, men kvaliteten varierer. Dette påvirker testing, kontinuerlig leveranse og overvåking.

Som nevnt tidligere vil outputen vi får komme igjennom tester med en status 200 fordi det i boka er riktig. Det som er ulempen med å bruke AI i dette tilfellet er at det krever et menneske på andre enden som kvalitetsjekker det som blir laget. I Wishifai sitt tilfelle kunne også upassende gaver-forslag blitt gitt til barn. Modellen var usikker på om barnerommet tilhørte et barn eller en voksen. Uten et menneske til å følge med på outputen hadde helt feil gaveforslag blitt gitt til helt feil aldersgruppe.

I min oppgave la jeg til en alarm som ga beskjed hvis bedrock bruker mer enn 30  sekunder på å respondere. Det den i midlertidig ikke kan gjøre er å hvis upassende gaveønsker blir gitt. Tekniske metriker som feilrate og latens er ikke nok. Det burde også følges med på svarlengde, svar som ikke kan tolkes og kostnader. Ved endringer i disse verdiene kan kvaliteten på outputten igjen bli enda dårligere. Å følge opp rapport fra kunder om dårlige forslag kan også være en god måte å overvåke applikasjonen på.

Da dette er en gave-forslags aplliksjon er ikke risikonivået veldig høyt ved AI bruk. Ved å bruke AI i for eksempel applikasjoner som gir ut økonomisk eller juridisk råd må eval-tester være et større krav før produksjon. Endringer i modell og prompten burde gå igjennom av mennesker og svarene burde kontrolleres før den sendes ut til kunder. Kort sagt: Jo høyere risiko, jo mer burde mennesker være innvolvert i det som sendes ut.