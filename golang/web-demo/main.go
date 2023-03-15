package main

import (
        "net/http"

        "github.com/gin-gonic/gin"
)

func statusOKHandler(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{"status": "success.welcome"})
}
func versionHandler(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{"version": "version 1.1"})
}
func main() {
        router := gin.New()
        router.Use(gin.Recovery())
        router.GET("/", statusOKHandler)
        router.GET("/version", versionHandler)
        router.Run(":8090")
}
