package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"

	_ "github.com/lib/pq"
)

type Product struct {
	ProductID   int     `json:"product_id"`
	ImageURL    string  `json:"image_url"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Price       float64 `json:"price"`
	Stock       int     `json:"stock"`
	CreatedAt   string  `json:"created_at"`
}

type Favorite struct {
	FavoriteID int    `json:"favorite_id"`
	UserID     int    `json:"user_id"`
	ProductID  int    `json:"product_id"`
	AddedAt    string `json:"added_at"`
}

type Cart struct {
	CartID    int    `json:"cart_id"`
	UserID    int    `json:"user_id"`
	ProductID int    `json:"product_id"`
	Quantity  int    `json:"quantity"`
	AddedAt   string `json:"added_at"`
}

var db *sql.DB

func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	(*w).Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
}

func productsHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")

	if r.Method == http.MethodOptions {
		return
	}

	switch {
	case r.URL.Path == "/products" && r.Method == http.MethodGet:
		getProductsHandler(w, r)
	case r.URL.Path == "/products" && r.Method == http.MethodPost:
		createProductHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/products/update/") && r.Method == http.MethodPut:
		updateProductHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/products/delete/") && r.Method == http.MethodDelete:
		deleteProductHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/products/") && r.Method == http.MethodGet:
		getProductByIDHandler(w, r)
	default:
		http.Error(w, "Not Found", http.StatusNotFound)
	}
}

func getProductsHandler(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT product_id, image_url, name, description, price, stock, created_at FROM Product")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	products := []Product{}
	for rows.Next() {
		var p Product
		err := rows.Scan(&p.ProductID, &p.ImageURL, &p.Name, &p.Description, &p.Price, &p.Stock, &p.CreatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		products = append(products, p)
	}
	json.NewEncoder(w).Encode(products)
}

func createProductHandler(w http.ResponseWriter, r *http.Request) {
	var newProduct Product
	err := json.NewDecoder(r.Body).Decode(&newProduct)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	err = db.QueryRow(
		"INSERT INTO Product (name, description, price, stock, image_url) VALUES ($1, $2, $3, $4, $5) RETURNING product_id, created_at",
		newProduct.Name, newProduct.Description, newProduct.Price, newProduct.Stock, newProduct.ImageURL,
	).Scan(&newProduct.ProductID, &newProduct.CreatedAt)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(newProduct)
}

func getProductByIDHandler(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/products/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	var p Product
	err = db.QueryRow("SELECT product_id, image_url, name, description, price, stock, created_at FROM Product WHERE product_id = $1", id).
		Scan(&p.ProductID, &p.ImageURL, &p.Name, &p.Description, &p.Price, &p.Stock, &p.CreatedAt)
	if err == sql.ErrNoRows {
		http.Error(w, "Product not found", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(p)
}

func updateProductHandler(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/products/update/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	var updatedProduct Product
	err = json.NewDecoder(r.Body).Decode(&updatedProduct)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	updatedProduct.ProductID = id
	err = db.QueryRow(
		"UPDATE Product SET name = $1, description = $2, price = $3, stock = $4, image_url = $5 WHERE product_id = $6 RETURNING created_at",
		updatedProduct.Name, updatedProduct.Description, updatedProduct.Price, updatedProduct.Stock, updatedProduct.ImageURL, id,
	).Scan(&updatedProduct.CreatedAt)
	if err == sql.ErrNoRows {
		http.Error(w, "Product not found", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(updatedProduct)
}

func deleteProductHandler(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/products/delete/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	result, err := db.Exec("DELETE FROM Product WHERE product_id = $1", id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if rowsAffected == 0 {
		http.Error(w, "Product not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func favoritesHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")

	if r.Method == http.MethodOptions {
		return
	}

	switch {
	case r.URL.Path == "/favorites" && r.Method == http.MethodGet:
		getFavoritesHandler(w, r)
	case r.URL.Path == "/favorites" && r.Method == http.MethodPost:
		addFavoriteHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/favorites/remove/") && r.Method == http.MethodDelete:
		removeFavoriteHandler(w, r)
	default:
		http.Error(w, "Not Found", http.StatusNotFound)
	}
}

func getFavoritesHandler(w http.ResponseWriter, r *http.Request) {
	userID := 1
	rows, err := db.Query(
		"SELECT p.product_id, p.image_url, p.name, p.description, p.price, p.stock, p.created_at FROM Favorites f JOIN Product p ON f.product_id = p.product_id WHERE f.user_id = $1",
		userID,
	)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	favorites := []Product{}
	for rows.Next() {
		var p Product
		err := rows.Scan(&p.ProductID, &p.ImageURL, &p.Name, &p.Description, &p.Price, &p.Stock, &p.CreatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		favorites = append(favorites, p)
	}
	json.NewEncoder(w).Encode(favorites)
}

func addFavoriteHandler(w http.ResponseWriter, r *http.Request) {
	userID := 1
	var fav struct {
		ProductID int `json:"product_id"`
	}
	err := json.NewDecoder(r.Body).Decode(&fav)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	_, err = db.Exec(
		"INSERT INTO Favorites (user_id, product_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
		userID, fav.ProductID,
	)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

func removeFavoriteHandler(w http.ResponseWriter, r *http.Request) {
	userID := 1
	idStr := strings.TrimPrefix(r.URL.Path, "/favorites/remove/")
	productID, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	result, err := db.Exec("DELETE FROM Favorites WHERE user_id = $1 AND product_id = $2", userID, productID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if rowsAffected == 0 {
		http.Error(w, "Favorite not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func cartHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")

	if r.Method == http.MethodOptions {
		return
	}

	switch {
	case r.URL.Path == "/cart" && r.Method == http.MethodGet:
		getCartHandler(w, r)
	case r.URL.Path == "/cart" && r.Method == http.MethodPost:
		addToCartHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/cart/update/") && r.Method == http.MethodPut:
		updateCartHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/cart/remove/") && r.Method == http.MethodDelete:
		removeFromCartHandler(w, r)
	default:
		http.Error(w, "Not Found", http.StatusNotFound)
	}
}

func getCartHandler(w http.ResponseWriter, r *http.Request) {
	userID := 1
	rows, err := db.Query(
		"SELECT p.product_id, p.image_url, p.name, p.description, p.price, p.stock, p.created_at, c.quantity FROM Cart c JOIN Product p ON c.product_id = p.product_id WHERE c.user_id = $1",
		userID,
	)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	type CartItem struct {
		Product  Product `json:"product"`
		Quantity int     `json:"quantity"`
	}
	cart := []CartItem{}
	for rows.Next() {
		var p Product
		var quantity int
		err := rows.Scan(&p.ProductID, &p.ImageURL, &p.Name, &p.Description, &p.Price, &p.Stock, &p.CreatedAt, &quantity)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		cart = append(cart, CartItem{Product: p, Quantity: quantity})
	}
	json.NewEncoder(w).Encode(cart)
}

func addToCartHandler(w http.ResponseWriter, r *http.Request) {
	userID := 1
	var item struct {
		ProductID int `json:"product_id"`
	}
	err := json.NewDecoder(r.Body).Decode(&item)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	var existingQuantity int
	err = db.QueryRow("SELECT quantity FROM Cart WHERE user_id = $1 AND product_id = $2", userID, item.ProductID).Scan(&existingQuantity)
	if err == sql.ErrNoRows {
		_, err = db.Exec("INSERT INTO Cart (user_id, product_id, quantity) VALUES ($1, $2, 1)", userID, item.ProductID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	} else if err == nil {
		_, err = db.Exec("UPDATE Cart SET quantity = $1 WHERE user_id = $2 AND product_id = $3", existingQuantity+1, userID, item.ProductID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	} else {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

func updateCartHandler(w http.ResponseWriter, r *http.Request) {
	userID := 1
	idStr := strings.TrimPrefix(r.URL.Path, "/cart/update/")
	productID, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	var item struct {
		Quantity int `json:"quantity"`
	}
	err = json.NewDecoder(r.Body).Decode(&item)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	if item.Quantity <= 0 {
		_, err = db.Exec("DELETE FROM Cart WHERE user_id = $1 AND product_id = $2", userID, productID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	} else {
		_, err = db.Exec("UPDATE Cart SET quantity = $1 WHERE user_id = $2 AND product_id = $3", item.Quantity, userID, productID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	}
	w.WriteHeader(http.StatusNoContent)
}

func removeFromCartHandler(w http.ResponseWriter, r *http.Request) {
	userID := 1
	idStr := strings.TrimPrefix(r.URL.Path, "/cart/remove/")
	productID, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	result, err := db.Exec("DELETE FROM Cart WHERE user_id = $1 AND product_id = $2", userID, productID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if rowsAffected == 0 {
		http.Error(w, "Cart item not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func main() {
	var err error
	connStr := "postgres://postgres:123123@localhost:5432/shop?sslmode=disable"
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		fmt.Println("Error connecting to the database:", err)
		os.Exit(1)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		fmt.Println("Error pinging the database:", err)
		os.Exit(1)
	}

	http.HandleFunc("/products", productsHandler)
	http.HandleFunc("/products/", productsHandler)
	http.HandleFunc("/favorites", favoritesHandler)
	http.HandleFunc("/favorites/remove/", favoritesHandler)
	http.HandleFunc("/cart", cartHandler)
	http.HandleFunc("/cart/update/", cartHandler)
	http.HandleFunc("/cart/remove/", cartHandler)

	fmt.Println("Server is running on port 8080!")
	http.ListenAndServe(":8080", nil)
}
