package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
)

// Product представляет продукт
type Product struct {
	ID          int     `json:"ID"`
	ImageURL    string  `json:"ImageURL"`
	Name        string  `json:"Name"`
	Description string  `json:"Description"`
	Price       float64 `json:"Price"`
}

// Пример списка продуктов
var products = []Product{
	{ID: 1, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-r/wc1000/7147386879.jpg", Name: "Acer Nitro V ANV15-41", Description: "Acer Nitro V ANV15-41, AMD Ryzen 7 7735HS Игровой ноутбук 15.6\", AMD Ryzen 7 7735HS, RAM 16 ГБ, SSD 512 ГБ, NVIDIA GeForce RTX 3050 (6 Гб), Без системы, (NH.QSHER.002), черный, Русская раскладка", Price: 81690},
	{ID: 2, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-g/wc1000/7050006328.jpg", Name: "Lenovo LOQ 15IAX9", Description: "Lenovo LOQ 15IAX9 Игровой ноутбук 15.6\", Intel Core i5-12450HX, RAM 16 ГБ, SSD 512 ГБ, NVIDIA GeForce RTX 4050 для ноутбуков (6 Гб), Без системы, (83GS00EPRK), серебристый, Русская раскладка.", Price: 84540},
	{ID: 3, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-q/wc1000/7126229138.jpg", Name: "Lenovo LOQ 15IRX9", Description: "Lenovo LOQ 15IRX9 Игровой ноутбук 15.6\", Intel Core i7-13650HX, RAM 16 ГБ, SSD 1024 ГБ, NVIDIA GeForce RTX 4060 (8 Гб), Без системы, (83DV00NJRK), серый, Русская раскладка", Price: 104490},
	{ID: 4, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-a/wc1000/7126230382.jpg", Name: "Lenovo Legion 5 16IRX9", Description: "Lenovo Legion 5 16IRX9 Игровой ноутбук 16\", Intel Core i7-14650HX, RAM 32 ГБ, SSD 1024 ГБ, NVIDIA GeForce RTX 4070 для ноутбуков (8 Гб), Без системы, (83DG00E0RK), серебристый, Русская раскладка.", Price: 151990},
	{ID: 5, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-7/wc1000/7076666203.jpg", Name: "Ninkear Super G16 Pro", Description: "Ninkear Super G16 Pro Игровой ноутбук 16\", Intel Core i9-10885H, RAM 32 ГБ, SSD 1024 ГБ, NVIDIA GeForce GTX 1650 Ti (4 Гб), Windows Pro, серый металлик, Русская раскладка", Price: 77732},
	{ID: 6, ImageURL: "https://ir.ozone.ru/s3/multimedia-n/wc1000/6834200027.jpg", Name: "VETAS 2024 ", Description: "VETAS 2024 Новое Последний выпуск Windows была активирована Игровой ноутбук 15.6\", Intel Celeron N5095, RAM 16 ГБ, SSD 512 ГБ, Intel UHD Graphics 750, Windows Pro, (N5905), серебристый, Русская раскладка.", Price: 21473},
	{ID: 7, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-c/wc1000/7152362724.jpg", Name: "N4000", Description: "N4000 Игровой ноутбук 15\", Intel Celeron N4000C, RAM 16 ГБ, SSD, Windows Pro, (M66-1), черно-серый, прозрачный, Русская раскладка", Price: 16504},
	{ID: 8, ImageURL: "https://ir.ozone.ru/s3/multimedia-v/wc1000/6776590459.jpg", Name: "UZZAI Lenovo Por x50", Description: "UZZAI Lenovo Por x50 Игровой ноутбук 15.6\", Intel Celeron N5095, RAM 24 ГБ, SSD, Intel HD Graphics 610, Windows Pro, (SC-976), черный, оливковый, Русская раскладка", Price: 23260},
	{ID: 9, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-7/wc1000/7034232355.jpg", Name: "TANSHI X15F RTX3050", Description: "TANSHI X15F RTX3050, RAM и SSD с возможностью расширения, новинка 2024 года Игровой ноутбук 15.6\", AMD Ryzen 5 6600H, RAM 16 ГБ, SSD 512 ГБ, NVIDIA GeForce RTX 3050 для ноутбуков (4 Гб), Linux, черный, Русская раскладка", Price: 71780},
	{ID: 10, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-1/wc1000/7152993169.jpg", Name: "Lenovo Legion Pro 5 16IRX9", Description: "Lenovo Legion Pro 5 16IRX9 Игровой ноутбук 16\", Intel Core i7-14650HX, RAM 32 ГБ, SSD 1024 ГБ, NVIDIA GeForce RTX 4060 (8 Гб), Без системы, (83DF00E3RK), серый, Русская раскладка", Price: 182900},
	{ID: 11, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-y/wc1000/7142706394.jpg", Name: "VANWIN N156", Description: "VANWIN N156 Игровой ноутбук 15.6\", Intel N95, RAM 16 ГБ, SSD 512 ГБ, Intel UHD Graphics 770, Windows Pro, (ноутбук для работы и учебы), черный, Русская раскладка", Price: 32500},
	{ID: 12, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-4/wc1000/7152993172.jpg", Name: "Lenovo Legion 7 16IRX9", Description: "Lenovo Legion 7 16IRX9 Игровой ноутбук 16\", Intel Core i7-14700HX, RAM 32 ГБ, SSD 1024 ГБ, NVIDIA GeForce RTX 4060 (8 Гб), Без системы, (83FD007DRK), черный, Русская раскладка", Price: 210990},
	{ID: 13, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-a/wc1000/7057184662.jpg", Name: "ASUS TUF Gaming A15 FA506NC-HN065", Description: "ASUS TUF Gaming A15 FA506NC-HN065 Игровой ноутбук, RAM 16 ГБ, черный", Price: 73566},
	{ID: 14, ImageURL: "https://ir.ozone.ru/s3/multimedia-r/wc1000/6834200067.jpg", Name: "VETAS 2024", Description: "VETAS 2024 Новое Последний выпуск Windows активирована Игровой ноутбук 15.6\", Intel Celeron N5095, RAM 32 ГБ, SSD 1024 ГБ, Intel UHD Graphics 750, Windows Pro, ( N5095), серебристый, Русская раскладка", Price: 31790},
	{ID: 15, ImageURL: "https://ir.ozone.ru/s3/multimedia-1-5/wc1000/7134536489.jpg", Name: "Lenovo LOQ 3 Series 15IAX9", Description: "Lenovo LOQ 3 Series 15IAX9 Игровой ноутбук 15.6\", Intel Core i5-12450HX, RAM 16 ГБ, SSD, NVIDIA GeForce RTX 4050 для ноутбуков (6 Гб), Без системы, (LOQ 3 Series 15IAX9), серый, Английская раскладка", Price: 112900},
}

func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	(*w).Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
}

func productsHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")

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

// Получить все продукты
func getProductsHandler(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(products)
}

// Создать продукт
func createProductHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var newProduct Product
	err := json.NewDecoder(r.Body).Decode(&newProduct)
	if err != nil {
		fmt.Println("Error decoding request body:", err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	var lastID int
	if len(products) > 0 {
		lastID = products[len(products)-1].ID
	}

	newProduct.ID = lastID + 1
	products = append(products, newProduct)

	json.NewEncoder(w).Encode(newProduct)
}

// Получить продукт по ID
func getProductByIDHandler(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/products/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}

	for _, product := range products {
		if product.ID == id {
			json.NewEncoder(w).Encode(product)
			return
		}
	}

	http.Error(w, "Product not found", http.StatusNotFound)
}

// Обновить продукт
func updateProductHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if r.Method != http.MethodPut {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

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

	for i, product := range products {
		if product.ID == id {
			updatedProduct.ID = id
			products[i] = updatedProduct
			json.NewEncoder(w).Encode(products[i])
			return
		}
	}

	http.Error(w, "Product not found", http.StatusNotFound)
}

// Удалить продукт
func deleteProductHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if r.Method != http.MethodDelete {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	idStr := strings.TrimPrefix(r.URL.Path, "/products/delete/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}

	for i, product := range products {
		if product.ID == id {
			products = append(products[:i], products[i+1:]...)
			w.WriteHeader(http.StatusNoContent)
			return
		}
	}

	http.Error(w, "Product not found", http.StatusNotFound)
}

func main() {
	http.HandleFunc("/products", productsHandler)
	http.HandleFunc("/products/", productsHandler)
	fmt.Println("Server is running on port 8080!")
	http.ListenAndServe(":8080", nil)
}
