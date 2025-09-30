#!/usr/bin/env python3
"""
GitHub Codespace Database Connection Debug Tool
Testet alle Datenbankverbindungen in der Codespace-Umgebung
"""

import os
import sys
import json
import asyncio
from datetime import datetime
import subprocess

try:
    import psycopg2
    PSYCOPG2_AVAILABLE = True
except ImportError:
    PSYCOPG2_AVAILABLE = False

try:
    import mysql.connector
    MYSQL_AVAILABLE = True
except ImportError:
    MYSQL_AVAILABLE = False

class CodespaceDatabaseDebugger:
    def __init__(self):
        self.codespace = os.getenv('CODESPACE_NAME')
        self.debug = os.getenv('DEBUG', 'false').lower() == 'true'
        
        self.databases = [
            {
                'name': 'Laravel API (PostgreSQL)',
                'type': 'postgresql',
                'host': 'localhost',
                'port': 5432,
                'database': 'mo_laravel_api_dev',
                'username': 'laravel_dev',
                'password_env': 'LARAVEL_DB_PASS'
            },
            {
                'name': 'CiviCRM (MariaDB/MySQL)', 
                'type': 'mysql',
                'host': 'localhost',
                'port': 3306,
                'database': 'mo_civicrm_dev',
                'username': 'civicrm_dev',
                'password_env': 'CIVICRM_DB_PASS'
            }
        ]
        
    def log(self, level, message):
        timestamp = datetime.now().isoformat()
        emoji = {
            'info': 'ℹ️',
            'success': '✅',
            'warning': '⚠️', 
            'error': '❌',
            'debug': '🔍'
        }.get(level, 'ℹ️')
        
        print(f"{timestamp} {emoji} [DB-DEBUG] {message}")
        
    def check_dependencies(self):
        """Prüft verfügbare Database-Treiber"""
        self.log('info', 'Checking database drivers...')
        
        drivers = {
            'psycopg2': PSYCOPG2_AVAILABLE,
            'mysql-connector': MYSQL_AVAILABLE
        }
        
        for driver, available in drivers.items():
            if available:
                self.log('success', f'{driver}: Available')
            else:
                self.log('error', f'{driver}: Missing - install with pip')
                
        return drivers
        
    def check_database_services(self):
        """Prüft ob Database-Services laufen"""
        self.log('info', 'Checking database services...')
        
        services = {
            'postgresql': 'sudo systemctl is-active postgresql',
            'mariadb': 'sudo systemctl is-active mariadb'
        }
        
        results = {}
        for service, command in services.items():
            try:
                result = subprocess.run(
                    command.split(),
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                
                if result.returncode == 0 and 'active' in result.stdout:
                    self.log('success', f'{service}: Running')
                    results[service] = True
                else:
                    self.log('warning', f'{service}: Not running or inactive')
                    results[service] = False
                    
            except Exception as e:
                self.log('error', f'{service}: Error checking - {str(e)}')
                results[service] = False
                
        return results
        
    def test_postgresql_connection(self, db_config):
        """Testet PostgreSQL Verbindung"""
        if not PSYCOPG2_AVAILABLE:
            return {'success': False, 'error': 'psycopg2 not available'}
            
        password = os.getenv(db_config['password_env'])
        if not password:
            return {'success': False, 'error': f"Password not found in {db_config['password_env']}"}
            
        try:
            conn = psycopg2.connect(
                host=db_config['host'],
                port=db_config['port'],
                database=db_config['database'],
                user=db_config['username'],
                password=password,
                connect_timeout=10
            )
            
            cursor = conn.cursor()
            cursor.execute('SELECT version();')
            version = cursor.fetchone()[0]
            
            cursor.execute('SELECT current_database();')
            current_db = cursor.fetchone()[0]
            
            cursor.close()
            conn.close()
            
            return {
                'success': True,
                'version': version,
                'database': current_db,
                'host': f"{db_config['host']}:{db_config['port']}"
            }
            
        except Exception as e:
            return {'success': False, 'error': str(e)}
            
    def test_mysql_connection(self, db_config):
        """Testet MySQL/MariaDB Verbindung"""
        if not MYSQL_AVAILABLE:
            return {'success': False, 'error': 'mysql-connector not available'}
            
        password = os.getenv(db_config['password_env'])
        if not password:
            return {'success': False, 'error': f"Password not found in {db_config['password_env']}"}
            
        try:
            conn = mysql.connector.connect(
                host=db_config['host'],
                port=db_config['port'], 
                database=db_config['database'],
                user=db_config['username'],
                password=password,
                connection_timeout=10
            )
            
            cursor = conn.cursor()
            cursor.execute('SELECT VERSION();')
            version = cursor.fetchone()[0]
            
            cursor.execute('SELECT DATABASE();')
            current_db = cursor.fetchone()[0]
            
            cursor.close()
            conn.close()
            
            return {
                'success': True,
                'version': version,
                'database': current_db,
                'host': f"{db_config['host']}:{db_config['port']}"
            }
            
        except Exception as e:
            return {'success': False, 'error': str(e)}
            
    def test_all_connections(self):
        """Testet alle Datenbankverbindungen"""
        self.log('info', 'Testing all database connections...')
        
        results = []
        
        for db_config in self.databases:
            self.log('info', f"Testing {db_config['name']}...")
            
            if db_config['type'] == 'postgresql':
                result = self.test_postgresql_connection(db_config)
            elif db_config['type'] == 'mysql':
                result = self.test_mysql_connection(db_config)
            else:
                result = {'success': False, 'error': 'Unknown database type'}
                
            results.append({
                'config': db_config,
                'result': result
            })
            
            if result['success']:
                self.log('success', f"{db_config['name']}: Connected")
                if self.debug:
                    self.log('debug', f"  Version: {result.get('version', 'Unknown')}")
                    self.log('debug', f"  Database: {result.get('database', 'Unknown')}")
                    self.log('debug', f"  Host: {result.get('host', 'Unknown')}")
            else:
                self.log('error', f"{db_config['name']}: {result['error']}")
                
        return results
        
    def generate_summary(self, drivers, services, connections):
        """Generiert Zusammenfassungsbericht"""
        print()
        print('📊 DATABASE CONNECTION SUMMARY')
        print('==============================')
        print()
        
        # Driver Summary
        print('🔧 Database Drivers:')
        for driver, available in drivers.items():
            status = '✅' if available else '❌'
            print(f'  {status} {driver}')
        print()
        
        # Services Summary  
        print('⚙️ Database Services:')
        for service, running in services.items():
            status = '✅' if running else '❌'
            print(f'  {status} {service}')
        print()
        
        # Connections Summary
        print('🗄️ Database Connections:')
        successful = 0
        total = len(connections)
        
        for conn in connections:
            name = conn['config']['name']
            success = conn['result']['success']
            status = '✅' if success else '❌'
            
            if success:
                successful += 1
                version = conn['result'].get('version', 'Unknown')[:50]
                print(f'  {status} {name} - {version}')
            else:
                error = conn['result']['error'][:50]
                print(f'  {status} {name} - {error}')
                
        print()
        
        # Overall Health
        driver_score = sum(drivers.values()) / len(drivers)
        service_score = sum(services.values()) / len(services) if services else 0
        connection_score = successful / total if total > 0 else 0
        
        overall_score = ((driver_score + service_score + connection_score) / 3) * 100
        
        if overall_score >= 90:
            grade = 'A'
            color = '🟢'
            message = 'All database connections operational!'
        elif overall_score >= 70:
            grade = 'B' 
            color = '🟡'
            message = 'Database connections need attention'
        else:
            grade = 'C'
            color = '🔴'
            message = 'Database connections have significant issues'
            
        print(f'{color} Database Health: {overall_score:.1f}% (Grade: {grade})')
        print(f'🎯 {message}')
        
        return {
            'drivers': drivers,
            'services': services, 
            'connections': connections,
            'summary': {
                'successful_connections': successful,
                'total_connections': total,
                'overall_score': overall_score,
                'grade': grade
            }
        }

def main():
    print('🔍 GITHUB CODESPACE - DATABASE CONNECTION DEBUG')
    print('===============================================')
    print()
    
    debugger = CodespaceDatabaseDebugger()
    
    # Environment Info
    if debugger.codespace:
        debugger.log('info', f'Running in GitHub Codespace: {debugger.codespace}')
    else:
        debugger.log('info', 'Running in local environment')
        
    print()
    
    # Check Dependencies
    drivers = debugger.check_dependencies()
    print()
    
    # Check Services
    services = debugger.check_database_services()
    print()
    
    # Test Connections
    connections = debugger.test_all_connections()
    print()
    
    # Generate Summary
    summary = debugger.generate_summary(drivers, services, connections)
    
    # Output JSON for automation
    if debugger.debug:
        print()
        print('🔍 DEBUG JSON OUTPUT:')
        print(json.dumps(summary, indent=2, default=str))

if __name__ == '__main__':
    main()