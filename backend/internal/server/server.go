// Package server wires the HTTP layer for the AI Pronunciation Coach API.
//
// At this stage it exposes only a liveness endpoint. Feature routes are added
// in later tasks and must not carry business logic in this package.
package server

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// NewRouter builds the Gin engine with the routes available at this stage.
func NewRouter() *gin.Engine {
	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery())

	r.GET("/health", health)

	return r
}

// health reports that the process is up and serving requests.
func health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
