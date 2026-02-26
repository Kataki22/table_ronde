#!/bin/bash

# Script de test pour vérifier que l'API fonctionne correctement

echo "🧪 Test de l'API TableRonde Backend"
echo "===================================="
echo ""

BASE_URL="http://localhost:3000"

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour tester un endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local description=$3
    
    echo -n "Testing $description... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" -X $method "$BASE_URL$endpoint")
    
    if [ $response -eq 200 ] || [ $response -eq 201 ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $response)"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC} (HTTP $response)"
        return 1
    fi
}

# Vérifier si le serveur est accessible
echo "1. Vérification de la connexion au serveur..."
if curl -s "$BASE_URL" > /dev/null; then
    echo -e "${GREEN}✓ Serveur accessible${NC}"
else
    echo -e "${RED}✗ Serveur non accessible${NC}"
    echo ""
    echo "Assurez-vous que le serveur est démarré avec: npm start"
    exit 1
fi

echo ""
echo "2. Test des endpoints..."

# Test GET endpoints
test_endpoint "GET" "/posts" "GET /posts"
test_endpoint "GET" "/posts/post_1" "GET /posts/:id"
test_endpoint "GET" "/profiles" "GET /profiles"
test_endpoint "GET" "/profiles/user_1" "GET /profiles/:id"
test_endpoint "GET" "/chats" "GET /chats"
test_endpoint "GET" "/messages" "GET /messages"
test_endpoint "GET" "/comments" "GET /comments"

echo ""
echo "3. Test de création de données..."

# Test POST - Créer un post
echo -n "Testing POST /posts... "
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/posts" \
    -H "Content-Type: application/json" \
    -d '{
        "id": "post_test_'$(date +%s)'",
        "authorId": "user_1",
        "authorName": "Test User",
        "authorUsername": "@testuser",
        "content": "Test post from script",
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
        "type": "text",
        "reactionCount": 0,
        "commentCount": 0,
        "shareCount": 0
    }')

if [ $response -eq 201 ]; then
    echo -e "${GREEN}✓ OK${NC} (HTTP $response)"
else
    echo -e "${RED}✗ FAILED${NC} (HTTP $response)"
fi

echo ""
echo "4. Test de filtrage..."

# Test query parameters
test_endpoint "GET" "/posts?authorId=user_1" "GET /posts?authorId=user_1"
test_endpoint "GET" "/messages?chatId=1" "GET /messages?chatId=1"

echo ""
echo "5. Statistiques..."

# Compter les ressources
posts_count=$(curl -s "$BASE_URL/posts" | grep -o '"id"' | wc -l)
profiles_count=$(curl -s "$BASE_URL/profiles" | grep -o '"id"' | wc -l)
chats_count=$(curl -s "$BASE_URL/chats" | grep -o '"id"' | wc -l)
messages_count=$(curl -s "$BASE_URL/messages" | grep -o '"id"' | wc -l)

echo "📊 Données disponibles:"
echo "   - Posts: $posts_count"
echo "   - Profils: $profiles_count"
echo "   - Chats: $chats_count"
echo "   - Messages: $messages_count"

echo ""
echo -e "${GREEN}✅ Tests terminés!${NC}"
echo ""
echo "💡 Conseils:"
echo "   - Utilisez http://localhost:3000 dans votre navigateur pour explorer l'API"
echo "   - Consultez SERVER_JSON_GUIDE.md pour plus d'informations"
echo "   - Lancez 'dart run scripts/generate_mock_data.dart' pour générer plus de données"
