-- Create the database
CREATE DATABASE IF NOT EXISTS student_records;
USE student_records;

-- Department table (1-to-Many with Student and Course)
CREATE TABLE department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    building VARCHAR(50) NOT NULL,
    budget DECIMAL(12,2) NOT NULL CHECK (budget > 0),
    established_date DATE NOT NULL
);

-- Student table
CREATE TABLE student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    department_id INT NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    graduation_date DATE,
    CONSTRAINT chk_graduation CHECK (graduation_date IS NULL OR graduation_date > enrollment_date),
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

-- Course table
CREATE TABLE course (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    credits TINYINT NOT NULL CHECK (credits > 0 AND credits <= 10),
    department_id INT NOT NULL,
    description TEXT,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

-- Instructor table
CREATE TABLE instructor (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    department_id INT NOT NULL,
    office_location VARCHAR(50),
    hire_date DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

-- Semester table
CREATE TABLE semester (
    semester_id INT AUTO_INCREMENT PRIMARY KEY,
    semester_name VARCHAR(50) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CONSTRAINT chk_semester_dates CHECK (end_date > start_date)
);

-- Enrollment table (M-to-M between Student and Course)
CREATE TABLE enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    grade DECIMAL(3,2) CHECK (grade IS NULL OR (grade >= 0 AND grade <= 4.0)),
    UNIQUE (student_id, course_id, semester_id),
    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES semester(semester_id) ON DELETE CASCADE
);

-- Course offering table (M-to-M between Course and Instructor)
CREATE TABLE course_offering (
    offering_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    instructor_id INT NOT NULL,
    semester_id INT NOT NULL,
    classroom VARCHAR(20) NOT NULL,
    schedule VARCHAR(100) NOT NULL,
    capacity SMALLINT NOT NULL CHECK (capacity > 0),
    UNIQUE (course_id, instructor_id, semester_id),
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (instructor_id) REFERENCES instructor(instructor_id) ON DELETE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES semester(semester_id) ON DELETE CASCADE
);

-- Address table (1-to-1 with Student)
CREATE TABLE student_address (
    student_id INT PRIMARY KEY,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'United States',
    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE
);

-- Financial record table (1-to-Many with Student)
CREATE TABLE financial_record (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    transaction_type ENUM('Tuition', 'Scholarship', 'Fee', 'Refund') NOT NULL,
    description VARCHAR(200),
    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE
);

-- Create indexes for performance
CREATE INDEX idx_student_name ON student(last_name, first_name);
CREATE INDEX idx_course_department ON course(department_id);
CREATE INDEX idx_enrollment_student ON enrollment(student_id);
CREATE INDEX idx_enrollment_course ON enrollment(course_id);
