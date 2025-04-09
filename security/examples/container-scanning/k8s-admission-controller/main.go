package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"

	"gopkg.in/yaml.v2"
	admissionv1 "k8s.io/api/admission/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Config defines the validator configuration
type Config struct {
	AllowedRegistries    []string `yaml:"allowedRegistries"`
	BlockedImages        []string `yaml:"blockedImages"`
	RequireImageSignature bool     `yaml:"requireImageSignature"`
	ScanThresholds       struct {
		Critical int `yaml:"critical"`
		High     int `yaml:"high"`
	} `yaml:"scanThresholds"`
	ExemptNamespaces []string `yaml:"exemptNamespaces"`
}

var config Config

func main() {
	// Load configuration
	configData, err := ioutil.ReadFile("/etc/webhook/config/config.yaml")
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}
	if err := yaml.Unmarshal(configData, &config); err != nil {
		log.Fatalf("Failed to parse configuration: %v", err)
	}

	// Set up HTTP server
	http.HandleFunc("/validate", validateHandler)
	http.HandleFunc("/health", healthHandler)

	// Start HTTPS server
	log.Print("Starting server on :8443")
	log.Fatal(http.ListenAndServeTLS(":8443", 
		"/etc/webhook/certs/tls.crt", 
		"/etc/webhook/certs/tls.key", 
		nil))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}

func validateHandler(w http.ResponseWriter, r *http.Request) {
	// Read the request body
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to read request body: %v", err), http.StatusBadRequest)
		return
	}

	// Parse the AdmissionReview request
	var admissionReviewReq admissionv1.AdmissionReview
	if err := json.Unmarshal(body, &admissionReviewReq); err != nil {
		http.Error(w, fmt.Sprintf("Failed to parse admission review: %v", err), http.StatusBadRequest)
		return
	}

	// Initialize AdmissionReview response
	admissionReviewResponse := admissionv1.AdmissionReview{
		TypeMeta: admissionReviewReq.TypeMeta,
		Response: &admissionv1.AdmissionResponse{
			UID: admissionReviewReq.Request.UID,
		},
	}

	// Check if namespace is exempt
	for _, ns := range config.ExemptNamespaces {
		if ns == admissionReviewReq.Request.Namespace {
			admissionReviewResponse.Response.Allowed = true
			sendResponse(w, admissionReviewResponse)
			return
		}
	}

	// Extract Pod from the request
	var pod corev1.Pod
	if err := json.Unmarshal(admissionReviewReq.Request.Object.Raw, &pod); err != nil {
		admissionReviewResponse.Response.Allowed = false
		admissionReviewResponse.Response.Result = &metav1.Status{
			Message: fmt.Sprintf("Failed to parse Pod object: %v", err),
		}
		sendResponse(w, admissionReviewResponse)
		return
	}

	// Validate container images
	allowed, message := validateImages(pod)
	admissionReviewResponse.Response.Allowed = allowed
	if !allowed {
		admissionReviewResponse.Response.Result = &metav1.Status{
			Message: message,
		}
	}

	// Send response
	sendResponse(w, admissionReviewResponse)
}

func sendResponse(w http.ResponseWriter, admissionReviewResponse admissionv1.AdmissionReview) {
	// Marshal the response
	responseBytes, err := json.Marshal(admissionReviewResponse)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to marshal admission review response: %v", err), http.StatusInternalServerError)
		return
	}

	// Send the response
	w.Header().Set("Content-Type", "application/json")
	w.Write(responseBytes)
}

func validateImages(pod corev1.Pod) (bool, string) {
	// Check all containers in the pod
	for _, container := range append(pod.Spec.Containers, pod.Spec.InitContainers...) {
		// 1. Check if image is from an allowed registry
		if !isFromAllowedRegistry(container.Image) {
			return false, fmt.Sprintf("Container %s uses image from disallowed registry: %s", container.Name, container.Image)
		}

		// 2. Check if image is blocked
		if isBlockedImage(container.Image) {
			return false, fmt.Sprintf("Container %s uses blocked image: %s", container.Name, container.Image)
		}

		// 3. Check if image is signed (this would typically call an external service)
		if config.RequireImageSignature && !isImageSigned(container.Image) {
			return false, fmt.Sprintf("Container %s uses unsigned image: %s", container.Name, container.Image)
		}

		// 4. Check vulnerability scan results (this would typically call an external service)
		criticalVulns, highVulns := getImageVulnerabilities(container.Image)
		if criticalVulns > config.ScanThresholds.Critical {
			return false, fmt.Sprintf("Container %s image has %d critical vulnerabilities (threshold: %d)", 
				container.Name, criticalVulns, config.ScanThresholds.Critical)
		}
		if highVulns > config.ScanThresholds.High {
			return false, fmt.Sprintf("Container %s image has %d high vulnerabilities (threshold: %d)", 
				container.Name, highVulns, config.ScanThresholds.High)
		}
	}

	return true, ""
}

func isFromAllowedRegistry(image string) bool {
	for _, registry := range config.AllowedRegistries {
		if strings.HasPrefix(image, registry) {
			return true
		}
	}
	return false
}

func isBlockedImage(image string) bool {
	for _, blockedImage := range config.BlockedImages {
		if blockedImage == "*:latest" && strings.HasSuffix(image, ":latest") {
			return true
		} else if image == blockedImage {
			return true
		}
	}
	return false
}

// Mock function - in a real implementation, this would call a signing verification service
func isImageSigned(image string) bool {
	// Placeholder for image signature verification
	// In a real implementation, this would check a signature store or service
	return !strings.HasSuffix(image, ":latest")  // For demo purposes, assume latest tags are unsigned
}

// Mock function - in a real implementation, this would call a vulnerability scanning service
func getImageVulnerabilities(image string) (critical, high int) {
	// Placeholder for vulnerability scanning results
	// In a real implementation, this would query a vulnerability database or service
	
	// For demo purposes, assume latest tags have more vulnerabilities
	if strings.HasSuffix(image, ":latest") {
		return 3, 7
	}
	return 0, 1
}
