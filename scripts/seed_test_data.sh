#!/bin/bash
# Script to seed test data for the Surf Mobile app

API_URL="${API_URL:-http://localhost:8080}"

echo "Seeding test data to API at $API_URL"
echo "======================================"
echo ""

# Colors for output.
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to make POST requests.
create_resource() {
    local endpoint=$1
    local data=$2
    local resource_name=$3
    
    echo -n "Creating $resource_name... " >&2
    
    # Use temporary files to avoid mixing stdout/stderr.
    local temp_response=$(mktemp)
    
    curl -s -w "\n%{http_code}" -X POST "$API_URL$endpoint" \
        -H "Content-Type: application/json" \
        -d "$data" > "$temp_response" 2>/dev/null
    
    http_code=$(tail -n1 "$temp_response")
    body=$(head -n -1 "$temp_response")
    
    if [ "$http_code" -eq 201 ] || [ "$http_code" -eq 200 ]; then
        echo -e "${GREEN}✓${NC}" >&2
        echo "$body" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*'
        rm -f "$temp_response"
        return 0
    else
        echo -e "${YELLOW}⚠ Already exists or error (HTTP $http_code)${NC}" >&2
        # Try to extract ID from error response or return first available.
        local extracted_id=$(echo "$body" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
        if [ -n "$extracted_id" ]; then
            echo "$extracted_id"
            rm -f "$temp_response"
            return 0
        fi
        rm -f "$temp_response"
        return 1
    fi
}

# Function to get first resource ID.
get_first_resource_id() {
    local endpoint=$1
    local temp_response=$(mktemp)
    
    curl -s "$API_URL$endpoint" > "$temp_response" 2>/dev/null
    
    local id=$(cat "$temp_response" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
    rm -f "$temp_response"
    echo "$id"
}

# 1. Get or Create School.
echo "1. Getting/Creating School..."
SCHOOL_ID=$(get_first_resource_id "/api/schools")

if [ -z "$SCHOOL_ID" ]; then
    SCHOOL_DATA='{
      "name": "Surf School Test",
      "tax_number": "123456789",
      "address": "123 Beach Street",
      "phone": "+1234567890",
      "email": "test@surfschool.com"
    }'
    SCHOOL_ID=$(create_resource "/api/schools" "$SCHOOL_DATA" "School")
fi

if [ -z "$SCHOOL_ID" ]; then
    echo -e "${RED}Failed to get/create school. Exiting.${NC}"
    exit 1
fi
echo "Using School ID: $SCHOOL_ID"
echo ""

# 2. Get or Create Teacher.
echo "2. Getting/Creating Teacher..."
TEACHER_ID=$(get_first_resource_id "/api/teachers")

if [ -z "$TEACHER_ID" ]; then
    TEACHER_DATA="{
      \"school_id\": $SCHOOL_ID,
      \"name\": \"John Surf Instructor\",
      \"tax_number\": \"987654321\",
      \"email\": \"john@surfschool.com\",
      \"phone\": \"+1234567891\",
      \"specialty\": \"Beginner Surf Lessons\",
      \"active\": true
    }"
    TEACHER_ID=$(create_resource "/api/teachers" "$TEACHER_DATA" "Teacher")
    # If creation failed, try to get again (might have been created).
    if [ -z "$TEACHER_ID" ]; then
        TEACHER_ID=$(get_first_resource_id "/api/teachers")
    fi
fi

if [ -z "$TEACHER_ID" ]; then
    echo -e "${RED}Failed to get/create teacher. Exiting.${NC}"
    exit 1
fi
echo "Using Teacher ID: $TEACHER_ID"
echo ""

# 3. Get or Create Student.
echo "3. Getting/Creating Student..."
STUDENT_ID=$(get_first_resource_id "/api/students")

if [ -z "$STUDENT_ID" ]; then
    STUDENT_DATA="{
      \"school_id\": $SCHOOL_ID,
      \"name\": \"Test Student\",
      \"tax_number\": \"111222333\",
      \"email\": \"student@test.com\",
      \"phone\": \"+1234567892\",
      \"active\": true
    }"
    STUDENT_ID=$(create_resource "/api/students" "$STUDENT_DATA" "Student")
fi

if [ -z "$STUDENT_ID" ]; then
    echo -e "${RED}Failed to get/create student. Exiting.${NC}"
    exit 1
fi
echo "Using Student ID: $STUDENT_ID"
echo ""

# 4. Get or Create Equipment Price.
echo "4. Getting/Creating Equipment Price..."
EQUIPMENT_PRICE_ID=$(curl -s "$API_URL/api/prices?type=equipment" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')

if [ -z "$EQUIPMENT_PRICE_ID" ]; then
    EQUIPMENT_PRICE_DATA="{
      \"school_id\": $SCHOOL_ID,
      \"type\": \"equipment\",
      \"description\": \"Surfboard Rental - Daily\",
      \"amount\": 25.00,
      \"active\": true
    }"
    EQUIPMENT_PRICE_ID=$(create_resource "/api/prices" "$EQUIPMENT_PRICE_DATA" "Equipment Price")
fi

if [ -z "$EQUIPMENT_PRICE_ID" ]; then
    echo -e "${RED}Failed to get/create equipment price. Exiting.${NC}"
    exit 1
fi
echo "Using Equipment Price ID: $EQUIPMENT_PRICE_ID"
echo ""

# 5. Get or Create Class Price.
echo "5. Getting/Creating Class Price..."
CLASS_PRICE_ID=$(curl -s "$API_URL/api/prices?type=class" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')

if [ -z "$CLASS_PRICE_ID" ]; then
    CLASS_PRICE_DATA="{
      \"school_id\": $SCHOOL_ID,
      \"type\": \"class\",
      \"description\": \"Surf Lesson - 1 Hour\",
      \"amount\": 50.00,
      \"active\": true
    }"
    CLASS_PRICE_ID=$(create_resource "/api/prices" "$CLASS_PRICE_DATA" "Class Price")
fi

if [ -z "$CLASS_PRICE_ID" ]; then
    echo -e "${RED}Failed to get/create class price. Exiting.${NC}"
    exit 1
fi
echo "Using Class Price ID: $CLASS_PRICE_ID"
echo ""

# 6. Create Equipment.
echo "6. Creating Equipment..."

EQUIPMENT_NAMES=("Surfboard - Shortboard" "Surfboard - Longboard" "Wetsuit - Full Body" "Leash" "Fins")
EQUIPMENT_TYPES=("surfboard" "surfboard" "wetsuit" "accessory" "accessory")
EQUIPMENT_IDS=()

for i in "${!EQUIPMENT_NAMES[@]}"; do
    EQUIPMENT_DATA="{
      \"school_id\": $SCHOOL_ID,
      \"name\": \"${EQUIPMENT_NAMES[$i]}\",
      \"type\": \"${EQUIPMENT_TYPES[$i]}\",
      \"description\": \"${EQUIPMENT_NAMES[$i]} for rental\",
      \"total_quantity\": 10,
      \"available_quantity\": 10,
      \"active\": true
    }"
    
    EQUIPMENT_ID=$(create_resource "/api/equipment" "$EQUIPMENT_DATA" "Equipment: ${EQUIPMENT_NAMES[$i]}")
    if [ -n "$EQUIPMENT_ID" ]; then
        EQUIPMENT_IDS+=($EQUIPMENT_ID)
    fi
done

if [ ${#EQUIPMENT_IDS[@]} -eq 0 ]; then
    echo -e "${RED}Failed to create equipment. Exiting.${NC}"
    exit 1
fi

echo "Created ${#EQUIPMENT_IDS[@]} equipment items"
echo ""

# 7. Create Classes.
echo "7. Creating Classes..."

# Get current date and time, use future dates to avoid conflicts.
TOMORROW=$(date -d "+1 day" +%Y-%m-%d)
DAY_AFTER_TOMORROW=$(date -d "+2 days" +%Y-%m-%d)
IN_3_DAYS=$(date -d "+3 days" +%Y-%m-%d)
IN_4_DAYS=$(date -d "+4 days" +%Y-%m-%d)

CLASS_TIMES=(
    "$TOMORROW 09:00:00|$TOMORROW 10:00:00"
    "$TOMORROW 14:00:00|$TOMORROW 15:00:00"
    "$DAY_AFTER_TOMORROW 10:00:00|$DAY_AFTER_TOMORROW 11:00:00"
    "$IN_3_DAYS 09:00:00|$IN_3_DAYS 10:00:00"
    "$IN_4_DAYS 14:00:00|$IN_4_DAYS 15:00:00"
)

CLASS_COUNT=0
for time_pair in "${CLASS_TIMES[@]}"; do
    START_TIME=$(echo $time_pair | cut -d'|' -f1)
    END_TIME=$(echo $time_pair | cut -d'|' -f2)
    
    # Convert to ISO 8601 format with Z timezone.
    START_ISO="${START_TIME// /T}Z"
    END_ISO="${END_TIME// /T}Z"
    
    # Create class with at least one student (required by API).
    CLASS_DATA="{
      \"school_id\": $SCHOOL_ID,
      \"teacher_id\": $TEACHER_ID,
      \"price_id\": $CLASS_PRICE_ID,
      \"start_datetime\": \"${START_ISO}\",
      \"end_datetime\": \"${END_ISO}\",
      \"student_ids\": [$STUDENT_ID],
      \"status\": \"scheduled\",
      \"notes\": \"Open class - students can join or leave\"
    }"
    
    CLASS_ID=$(create_resource "/api/classes" "$CLASS_DATA" "Class at $START_TIME")
    if [ -n "$CLASS_ID" ]; then
        CLASS_COUNT=$((CLASS_COUNT + 1))
    fi
done

echo "Created $CLASS_COUNT classes"
echo ""

# Summary.
echo "======================================"
echo -e "${GREEN}Test data created successfully!${NC}"
echo ""
echo "Summary:"
echo "  School ID: $SCHOOL_ID"
echo "  Teacher ID: $TEACHER_ID"
echo "  Student ID: $STUDENT_ID"
echo "  Equipment Price ID: $EQUIPMENT_PRICE_ID"
echo "  Class Price ID: $CLASS_PRICE_ID"
echo "  Equipment IDs: ${EQUIPMENT_IDS[*]}"
echo "  Classes created: $CLASS_COUNT"
echo ""
echo -e "${YELLOW}Note: Student ID $STUDENT_ID can be used in the mobile app for testing.${NC}"
echo ""

