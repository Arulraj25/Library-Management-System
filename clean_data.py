import csv
import re
from datetime import datetime

def clean_books():
    """Clean books.csv and save as books_cleaned.csv"""
    print("Cleaning books.csv...")
    
    try:
        # Try different encodings
        encodings = ['latin-1', 'iso-8859-1', 'cp1252', 'utf-8']
        rows = []
        
        for encoding in encodings:
            try:
                with open('books.csv', 'r', encoding=encoding) as f:
                    # Read the entire content
                    content = f.read()
                    print(f"Successfully read with {encoding} encoding")
                    
                    # Handle semicolon delimiter
                    lines = content.strip().split('\n')
                    
                    # Parse CSV with semicolon delimiter
                    reader = csv.reader(lines, delimiter=';', quotechar='"')
                    rows = list(reader)
                    break
            except UnicodeDecodeError:
                continue
        
        if not rows:
            print("❌ Could not read books.csv with any encoding")
            return 0
        
        cleaned = []
        seen_isbns = set()
        
        for i, row in enumerate(rows):
            if i == 0:  # Header row
                cleaned.append(row)
                continue
            
            if len(row) < 8:
                # Pad row if needed
                row = row + [''] * (8 - len(row))
            
            isbn = row[0].strip().strip('"')
            if not isbn or isbn in seen_isbns:
                continue
            seen_isbns.add(isbn)
            
            # Clean each field
            cleaned_row = [
                isbn,                                     # ISBN
                row[1].strip().strip('"'),                # Title
                row[2].strip().strip('"'),                # Author
                '',                                       # Year
                row[4].strip().strip('"').replace('&amp;', '&'),  # Publisher
                row[5].strip().strip('"') if len(row) > 5 else '',  # Image URL S
                row[6].strip().strip('"') if len(row) > 6 else '',  # Image URL M
                row[7].strip().strip('"') if len(row) > 7 else ''   # Image URL L
            ]
            
            # Clean year - remove quotes and convert
            year_str = row[3].strip().strip('"')
            if year_str:
                try:
                    # Remove any non-digit characters
                    year_str_clean = re.sub(r'\D', '', year_str)
                    if year_str_clean:
                        year = int(year_str_clean)
                        if 1800 <= year <= datetime.now().year:
                            cleaned_row[3] = str(year)
                except ValueError:
                    pass
            
            cleaned.append(cleaned_row)
        
        # Save cleaned data to new CSV file
        with open('books_cleaned.csv', 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerows(cleaned)
        
        print(f"✅ Saved {len(cleaned)-1} books to 'books_cleaned.csv'")
        return len(cleaned)-1
        
    except FileNotFoundError:
        print("❌ Error: books.csv not found!")
        return 0
    except Exception as e:
        print(f"❌ Error: {e}")
        return 0

def clean_students():
    """Clean students.csv and save as students_cleaned.csv"""
    print("\nCleaning students.csv...")
    
    try:
        # Try different encodings
        encodings = ['latin-1', 'iso-8859-1', 'cp1252', 'utf-8']
        rows = []
        
        for encoding in encodings:
            try:
                with open('students.csv', 'r', encoding=encoding) as f:
                    reader = csv.reader(f)
                    rows = list(reader)
                    print(f"Successfully read with {encoding} encoding")
                    break
            except UnicodeDecodeError:
                continue
        
        if not rows:
            print("❌ Could not read students.csv with any encoding")
            return 0
        
        cleaned = []
        seen_ids = set()
        
        for i, row in enumerate(rows):
            if i == 0:  # Header row
                cleaned.append(row)
                continue
            
            if len(row) < 7:
                continue
            
            student_id = row[0].strip().upper()
            if not student_id or student_id in seen_ids:
                continue
            seen_ids.add(student_id)
            
            # Clean each field
            cleaned_row = [
                student_id,                           # student_id
                row[1].strip().title(),               # first_name
                row[2].strip().title(),               # last_name
                '',                                   # email
                row[4].strip(),                       # phone
                row[5].strip(),                       # enrollment_date
                'INACTIVE'                            # status
            ]
            
            # Fix email - special handling for your format
            email = row[3].strip()
            if email:
                # Remove leading @
                if email.startswith('@'):
                    email = email[1:]
                
                # For the format "@university.edu @college.edu @student.edu"
                # Let's use the first domain
                email_parts = email.split()
                if email_parts:
                    # Take the first email-like part
                    first_email = email_parts[0]
                    # Remove @ if at start
                    if first_email.startswith('@'):
                        first_email = first_email[1:]
                    # Add a username if missing
                    if '@' not in first_email:
                        # Use first name + last initial as username
                        username = row[1].strip().lower() + row[2].strip()[0].lower()
                        cleaned_row[3] = f"{username}@{first_email}"
                    else:
                        cleaned_row[3] = first_email.lower()
            
            # Format phone number
            phone = row[4].strip()
            if phone:
                # Remove parentheses, spaces, dashes
                digits = re.sub(r'\D', '', phone)
                if len(digits) == 10:
                    cleaned_row[4] = f"({digits[:3]}) {digits[3:6]}-{digits[6:]}"
                else:
                    cleaned_row[4] = phone
            
            # Format date
            date_str = row[5].strip()
            if date_str:
                try:
                    date_obj = datetime.strptime(date_str, '%Y-%m-%d')
                    cleaned_row[5] = date_obj.strftime('%Y-%m-%d')
                except ValueError:
                    # Try other formats if needed
                    pass
            
            # Standardize status
            if len(row) > 6:
                status = row[6].strip().upper()
                if status == 'ACTIVE':
                    cleaned_row[6] = 'ACTIVE'
            
            cleaned.append(cleaned_row)
        
        # Save cleaned data to new CSV file
        with open('students_cleaned.csv', 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerows(cleaned)
        
        print(f"✅ Saved {len(cleaned)-1} students to 'students_cleaned.csv'")
        return len(cleaned)-1
        
    except FileNotFoundError:
        print("❌ Error: students.csv not found!")
        return 0
    except Exception as e:
        print(f"❌ Error: {e}")
        return 0

def show_file_contents(filename):
    """Show first few lines of a file"""
    try:
        print(f"\n--- First 3 lines of {filename} ---")
        with open(filename, 'r', encoding='utf-8') as f:
            for i, line in enumerate(f):
                if i < 3:
                    print(line.strip())
                else:
                    break
        if i >= 2:
            print("...")
    except FileNotFoundError:
        print(f"File {filename} not found")
    except UnicodeDecodeError:
        print(f"Cannot read {filename} with UTF-8 encoding")

def main():
    print("="*50)
    print("CSV DATA CLEANER")
    print("="*50)
    
    # Show original files
    print("\n📁 Original files:")
    show_file_contents('books.csv')
    show_file_contents('students.csv')
    
    # Clean the files
    books_count = clean_books()
    students_count = clean_students()
    
    # Show cleaned files
    print("\n📁 Cleaned files:")
    show_file_contents('books_cleaned.csv')
    show_file_contents('students_cleaned.csv')
    
    # Summary
    print("\n" + "="*50)
    print("SUMMARY")
    print("="*50)
    print(f"📚 Books cleaned: {books_count}")
    print(f"👥 Students cleaned: {students_count}")
    
    if books_count > 0 and students_count > 0:
        print("\n✅ All files cleaned successfully!")
    else:
        print("\n⚠️  Some files may not have been cleaned")
    
    print(f"\n📁 Output files:")
    if books_count > 0:
        print(f"   - books_cleaned.csv")
    if students_count > 0:
        print(f"   - students_cleaned.csv")
    print("="*50)

if __name__ == "__main__":
    main()