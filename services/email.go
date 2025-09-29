package services

import (
	"fmt"
	"net/smtp"

	"go-click-exprice-backend/config"
)

type EmailService struct {
	config *config.SMTPConfig
}

func NewEmailService(cfg *config.SMTPConfig) *EmailService {
	return &EmailService{
		config: cfg,
	}
}

func (es *EmailService) SendContactEmail(name, email, subject, message string) error {
	if es.config.Username == "" || es.config.Password == "" {
		return fmt.Errorf("SMTP credentials not configured")
	}

	// Email content
	to := es.config.AdminEmail
	msg := fmt.Sprintf("From: %s\r\nTo: %s\r\nSubject: New Contact Form Submission\r\n\r\nName: %s\r\nEmail: %s\r\nSubject: %s\r\nMessage: %s\r\n",
		email, to, name, email, subject, message)

	// SMTP authentication
	auth := smtp.PlainAuth("", es.config.Username, es.config.Password, es.config.Host)

	// Send email
	err := smtp.SendMail(
		fmt.Sprintf("%s:%d", es.config.Host, es.config.Port),
		auth,
		email,
		[]string{to},
		[]byte(msg),
	)

	return err
}

func (es *EmailService) SendConfirmationEmail(to, name string) error {
	if es.config.Username == "" || es.config.Password == "" {
		return fmt.Errorf("SMTP credentials not configured")
	}

	subject := "Thank you for contacting us"
	msg := fmt.Sprintf("From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\nDear %s,\r\n\r\nThank you for contacting us. We have received your message and will get back to you soon.\r\n\r\nBest regards,\r\nClick Exprice Team\r\n",
		es.config.Username, to, subject, name)

	auth := smtp.PlainAuth("", es.config.Username, es.config.Password, es.config.Host)

	err := smtp.SendMail(
		fmt.Sprintf("%s:%d", es.config.Host, es.config.Port),
		auth,
		es.config.Username,
		[]string{to},
		[]byte(msg),
	)

	return err
}
