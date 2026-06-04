

#                GENERATION DE LA CARTE INTERACTIVE ET PERFORMANTE




# Installation des packages (à ne faire qu'une seule fois si nécessaire)

# install.packages("leaflet", dependencies = TRUE, force = TRUE)
# install.packages("leaflet.extras", dependencies = TRUE, force = TRUE)
# install.packages("leaflet.extras2", dependencies = TRUE, force = TRUE)

# Exploitation des bibliothèques

library(magrittr)
library(leaflet)
library(leaflet.extras)
library(leaflet.extras2) #barre de recherche

# Préparation des données pour la carte

# On repart directement du fichier nettoyé irve_clean

data_carte <- irve_clean %>%
  mutate(
    # Conversion explicite en numérique
    puissance_nominale = as.numeric(puissance_nominale),
    # Création du label textuel pour que la recherche et le survol affichent la ville
    commune_recherche = paste0(toupper(consolidated_commune), " (", puissance_nominale, " kW )")
  )

# Construction de la carte optimisée, fluide et interactive

carte_performante <- leaflet(data = data_carte) %>%
  addTiles() %>%
  setView(lng = 2.35, lat = 46.60, zoom = 6) %>%
  
  # COUCHE superficiel : La carte de chaleur (Visible uniquement de loin)
  
  addHeatmap(
    lng = ~consolidated_longitude,
    lat = ~consolidated_latitude,
    blur = 20,
    max = 0.05,
    radius = 15,
    group = "Chaleur"
  ) %>%
  
  # COUCHE de quand on agrandit genre on zoom : Les points précis (Visible uniquement de près)
  addCircleMarkers(
    lng = ~consolidated_longitude,
    lat = ~consolidated_latitude,
    radius = 4,
    color = "#0078AA",
    fillColor = "#00FFDD",
    fillOpacity = 0.8,
    weight = 1,
    label = ~commune_recherche, # On utilise la colonne textuelle "VILLE (kW)"
    popup = ~paste0(
      "<strong>Station :</strong> ", nom_station, "<br>",
      "<strong>Enseigne :</strong> ", nom_enseigne, "<br>",
      "<strong>Adresse :</strong> ", adresse_station, "<br>",
      "<strong>Puissance :</strong> ", puissance_nominale, " kW<br>",
      "<strong>Nombre de prises :</strong> ", nbre_pdc
    ),
    group = "Bornes Precises"
  ) %>%
  
  # GESTION DU ZOOM : Transition automatique
  
  # La chaleur s'affiche du zoom 1 à 11 (Vue France / Région) et disparaît après
  
  groupOptions("Chaleur", zoomLevels = 1:11) %>%
  
  # Les points précis n'existent qu'à partir du zoom 12 (Vue Ville / Rue)
  
  groupOptions("Bornes Precises", zoomLevels = 12:20) %>% # Ajout du %>% pour lier la recherche
  
  # BARRE DE RECHERCHE PAR VILLE 
  
  addSearchFeatures(
    targetGroups = "Bornes Precises",
    options = searchFeaturesOptions(
      propertyName = "label",     # Cherche dans le paramètre 'label' (commune_recherche)
      zoom = 14,                  # Zoom automatique sur la ville trouvée
      openPopup = TRUE,           # Ouvre directement la bulle d'info de la borne
      textPlaceholder = "Entrer le nom de la ville (ex: BREST)..."
    )
  )

# Afficher la carte

carte_performante