package main

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"net/http"
)

func handleRequest(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	res := events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Headers:    map[string]string{"Content-Type": "application/json; charset=utf-8"},
		Body:       "{\"message\":\"Hello gophers!\",\"architecture\":\"x86_64\"}",
	}
	return res, nil
}

func main() {
	lambda.Start(handleRequest)
}
