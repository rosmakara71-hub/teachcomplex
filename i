<!DOCTYPE html>
<html lang="km">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ប្រព័ន្ធប្រឡងគណិតវិទ្យា</title>
    <!-- Tailwind CSS សម្រាប់រចនា -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- MathJax Configuration សម្រាប់រូបមន្តគណិតវិទ្យា -->
    <script>
        MathJax = {
            tex: { inlineMath: [['$', '$'], ['\\(', '\\)']] },
            svg: { fontCache: 'global' }
        };
    </script>
    <script type="text/javascript" id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js"></script>

    <style>
        /* Watermark Design */
        .watermark {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-45deg);
            font-size: 8rem;
            color: rgba(0, 0, 0, 0.03);
            z-index: -1;
            white-space: nowrap;
            pointer-events: none;
            user-select: none;
        }

        /* Highlight ជម្រើសដែលសិស្សបានជ្រើសរើស */
        .option-label {
            transition: all 0.2s ease;
        }
        .option-label.selected {
            background-color: #dbeafe; /* Tailwind bg-blue-100 */
            border-color: #3b82f6; /* Tailwind border-blue-500 */
        }
        
        /* លាក់ Page ផ្សេងៗ ពេល Pagination */
        .question-page { display: none; }
        .question-page.active { display: block; }
    </style>
</head>
<body class="bg-gray-50 text-gray-800 font-sans relative min-h-screen">

    <!-- Watermark -->
    <div class="watermark">វិទ្យាល័យចំណេះដឹងទូទៅ</div>

    <!-- ==================== 1. ផ្ទាំងស្វាគមន៍ (Welcome Screen) ==================== -->
    <div id="welcome-screen" class="max-w-md mx-auto mt-20 bg-white p-8 rounded-xl shadow-lg text-center">
        <h1 class="text-2xl font-bold text-blue-600 mb-4">ប្រឡងប្រជែងសមត្ថភាពគណិតវិទ្យា</h1>
        <p class="text-gray-600 mb-6">សូមបញ្ចូលឈ្មោះរបស់អ្នកដើម្បីចាប់ផ្តើមការប្រឡង</p>
        <input type="text" id="student-name" placeholder="ឈ្មោះសិស្ស..." class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500 mb-4" autocomplete="off">
        <button id="start-btn" onclick="startExam()" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition">ចាប់ផ្តើមប្រឡង</button>
    </div>

    <!-- ==================== 2. ផ្ទាំងប្រឡង (Exam Screen) ==================== -->
    <div id="exam-screen" class="max-w-3xl mx-auto mt-10 bg-white p-8 rounded-xl shadow-lg hidden">
        <div class="flex justify-between items-center border-b pb-4 mb-6">
            <div>
                <p class="text-sm text-gray-500">បេក្ខជន</p>
                <h2 id="display-name" class="text-xl font-bold text-blue-700"></h2>
            </div>
            <div class="text-right">
                <p class="text-sm text-gray-500">រយៈពេល</p>
                <h2 id="timer-display" class="text-xl font-bold text-red-600">00:00</h2>
            </div>
        </div>

        <div id="questions-container"></div>

        <div class="flex justify-between mt-8 border-t pt-4">
            <button id="prev-btn" onclick="changePage(-1)" class="bg-gray-200 hover:bg-gray-300 text-gray-800 px-6 py-2 rounded-lg hidden">ថយក្រោយ</button>
            <div id="page-indicator" class="text-gray-600 font-medium self-center"></div>
            <button id="next-btn" onclick="changePage(1)" class="bg-blue-100 hover:bg-blue-200 text-blue-800 px-6 py-2 rounded-lg">បន្ទាប់</button>
            <button id="submit-btn" onclick="submitExam()" class="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg hidden">បញ្ជូនចម្លើយ</button>
        </div>
    </div>

    <!-- ==================== 3. ផ្ទាំងលទ្ធផល (Result Screen) ==================== -->
    <div id="result-screen" class="max-w-3xl mx-auto mt-10 bg-white p-8 rounded-xl shadow-lg hidden">
        <div class="text-center mb-8 border-b pb-6">
            <h1 class="text-3xl font-bold text-gray-800 mb-2">លទ្ធផលនៃការប្រឡង</h1>
            <p id="display-date" class="text-gray-500 mb-4"></p>
            <div class="inline-block bg-blue-50 border-2 border-blue-200 rounded-2xl p-6">
                <p class="text-lg text-gray-600">ពិន្ទុសរុបរបស់អ្នកគឺ</p>
                <h2 id="score-display" class="text-5xl font-extrabold text-blue-600 mt-2"></h2>
            </div>
        </div>

        <h3 class="text-xl font-bold text-gray-800 mb-4">កែតម្រូវ និងដំណោះស្រាយ៖</h3>
        <div id="review-container" class="space-y-6"></div>
        
        <div class="text-center mt-8 pt-6 border-t">
            <button onclick="location.reload()" class="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 rounded-lg font-bold">ត្រឡប់ទៅដើមវិញ</button>
        </div>
    </div>

    <script>
        // ==================== ទិន្នន័យសំណួរ ====================
        const questions = [
            {
                id: 1,
                question: "រកដេរីវេនៃអនុគមន៍ $f(x) = x^2 + 2x + 5$",
                options: ["$2x + 5$", "$2x + 2$", "$x + 2$", "$2x^2 + 2$"],
                answer: 1, // Index ទី 1 គឺ "$2x + 2$"
                solution: "តាមរូបមន្ត $(x^n)' = nx^{n-1}$ និង $(c)' = 0$ យើងបាន $f'(x) = 2x + 2 + 0 = 2x + 2$"
            },
            {
                id: 2,
                question: "គណនាអាំងតេក្រាលកំណត់ $\\int_{0}^{1} 2x \\, dx$",
                options: ["$0$", "$2$", "$1$", "$1/2$"],
                answer: 2, // Index ទី 2 គឺ "$1$"
                solution: "$\\int 2x \\, dx = x^2$។ ជំនួសគោល $\\left[ x^2 \\right]_0^1 = 1^2 - 0^2 = 1$"
            },
            {
                id: 3,
                question: "ដោះស្រាយសមីការអិចស្ប៉ូណង់ស្យែល $2^{x+1} = 16$",
                options: ["$x = 2$", "$x = 3$", "$x = 4$", "$x = 1$"],
                answer: 1,
                solution: "$2^{x+1} = 16 \\Rightarrow 2^{x+1} = 2^4 \\Rightarrow x + 1 = 4 \\Rightarrow x = 3$"
            },
            {
                id: 4,
                question: "គណនាលីមីត $\\lim_{x \\to 2} \\frac{x^2 - 4}{x - 2}$",
                options: ["$0$", "$2$", "$4$", "$\\infty$"],
                answer: 2,
                solution: "រាង $\\frac{0}{0}$ ។ ផ្តាច់ជាកត្តា៖ $\\lim_{x \\to 2} \\frac{(x-2)(x+2)}{x-2} = \\lim_{x \\to 2} (x+2) = 2 + 2 = 4$"
            }
        ];

        // ==================== អថេរសម្រាប់ដំណើរការ ====================
        let userAnswers = {};
        let timerInterval;
        let seconds = 0;
        let currentPage = 1;
        const questionsPerPage = 2; // កំណត់ចំនួនសំណួរក្នុងមួយទំព័រ
        const totalPages = Math.ceil(questions.length / questionsPerPage);

        // ==================== ការពារការ Refresh ====================
        window.addEventListener('beforeunload', function (e) {
            if (document.getElementById('exam-screen').style.display === 'block') {
                e.preventDefault();
                e.returnValue = '';
            }
        });

        // ==================== ចុច Enter ដើម្បីចាប់ផ្តើម ====================
        document.getElementById('student-name').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                startExam();
            }
        });

        // ==================== អនុគមន៍ចាប់ផ្តើមប្រឡង ====================
        function startExam() {
            const nameInput = document.getElementById('student-name').value.trim();
            if (nameInput === "") {
                alert("សូមបញ្ចូលឈ្មោះរបស់អ្នក!");
                return;
            }

            // សុវត្ថិភាព (Security) ប្រើប្រាស់ innerText ការពារ XSS
            document.getElementById('display-name').innerText = nameInput;
            
            document.getElementById('welcome-screen').style.display = 'none';
            document.getElementById('exam-screen').style.display = 'block';

            renderQuestions();
            startTimer();
        }

        // ==================== រៀបចំសំណួរ និង Pagination ====================
        function renderQuestions() {
            const container = document.getElementById('questions-container');
            container.innerHTML = '';
            
            let pageHtml = '';
            let pageCount = 1;

            questions.forEach((q, index) => {
                if (index % questionsPerPage === 0) {
                    // បង្កើតទំព័រថ្មី
                    pageHtml += `<div class="question-page ${pageCount === 1 ? 'active' : ''}" id="page-${pageCount}">`;
                    pageCount++;
                }

                pageHtml += `
                    <div class="mb-6 p-5 border border-gray-200 rounded-xl bg-gray-50">
                        <p class="font-semibold text-lg mb-4">សំណួរទី ${index + 1}: ${q.question}</p>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-3" data-question-id="${q.id}">
                `;

                q.options.forEach((opt, optIndex) => {
                    pageHtml += `
                        <label class="option-label flex items-center p-3 border border-gray-300 rounded-lg cursor-pointer bg-white hover:bg-gray-100">
                            <input type="radio" name="q${q.id}" value="${optIndex}" class="mr-3 w-5 h-5 text-blue-600">
                            <span class="text-gray-700">${opt}</span>
                        </label>
                    `;
                });

                pageHtml += `</div></div>`;

                if ((index + 1) % questionsPerPage === 0 || index === questions.length - 1) {
                    pageHtml += `</div>`; // បិទទំព័រ
                }
            });

            container.innerHTML = pageHtml;
            updatePaginationControls();

            // បញ្ជាឱ្យ MathJax ធ្វើការ Render តែចំពោះ Container ដែលទើបបង្កើត (ចំណេញ Performance)
            MathJax.typesetPromise([container]);
        }

        // ==================== Event Delegation សម្រាប់ការ Highlight ====================
        document.getElementById('questions-container').addEventListener('change', function(e) {
            if (e.target.type === 'radio') {
                const questionDiv = e.target.closest('.grid');
                const labels = questionDiv.querySelectorAll('.option-label');
                
                // ដកការ Highlight ពីគ្រប់ជម្រើសក្នុងសំណួរនេះ
                labels.forEach(label => label.classList.remove('selected'));
                
                // ដាក់ការ Highlight តែជម្រើសដែលចុច
                e.target.closest('.option-label').classList.add('selected');

                // រក្សាទុកចម្លើយ
                const qId = questionDiv.getAttribute('data-question-id');
                userAnswers[qId] = parseInt(e.target.value);
            }
        });

        // ==================== ប្តូរទំព័រ (Pagination Logic) ====================
        function changePage(direction) {
            document.getElementById(`page-${currentPage}`).classList.remove('active');
            currentPage += direction;
            document.getElementById(`page-${currentPage}`).classList.add('active');
            updatePaginationControls();
        }

        function updatePaginationControls() {
            document.getElementById('prev-btn').style.display = currentPage === 1 ? 'none' : 'block';
            document.getElementById('page-indicator').innerText = `ទំព័រ ${currentPage} នៃ ${totalPages}`;
            
            if (currentPage === totalPages) {
                document.getElementById('next-btn').style.display = 'none';
                document.getElementById('submit-btn').style.display = 'block';
            } else {
                document.getElementById('next-btn').style.display = 'block';
                document.getElementById('submit-btn').style.display = 'none';
            }
        }

        // ==================== ពេលវេលា (Timer) ====================
        function startTimer() {
            const timerDisplay = document.getElementById('timer-display');
            timerInterval = setInterval(() => {
                seconds++;
                const mins = Math.floor(seconds / 60).toString().padStart(2, '0');
                const secs = (seconds % 60).toString().padStart(2, '0');
                timerDisplay.innerText = `${mins}:${secs}`;
            }, 1000);
        }

        // ==================== បញ្ជូនការប្រឡង (Submit) ====================
        function submitExam() {
            if(Object.keys(userAnswers).length < questions.length) {
                if(!confirm("អ្នកមិនទាន់បានឆ្លើយសំណួរទាំងអស់ទេ។ តើអ្នកពិតជាចង់បញ្ជូនលទ្ធផលមែនទេ?")) {
                    return;
                }
            }

            clearInterval(timerInterval);
            document.getElementById('exam-screen').style.display = 'none';
            document.getElementById('result-screen').style.display = 'block';
            
            // កាលបរិច្ឆេទជាភាសាខ្មែរ
            document.getElementById('display-date').innerText = getKhmerDate();

            renderReview();
        }

        // ==================== ពិនិត្យកែតម្រូវ និងដាក់ពិន្ទុ ====================
        function renderReview() {
            let score = 0;
            const reviewContainer = document.getElementById('review-container');
            let reviewHtml = '';

            questions.forEach((q, index) => {
                const userAnswer = userAnswers[q.id];
                const isCorrect = userAnswer === q.answer;
                
                if (isCorrect) score++;

                let statusBadge = '';
                let borderClass = '';

                if (userAnswer === undefined) {
                    statusBadge = '<span class="bg-yellow-100 text-yellow-800 text-xs font-bold px-2 py-1 rounded">មិនបានឆ្លើយ</span>';
                    borderClass = 'border-yellow-300';
                } else if (isCorrect) {
                    statusBadge = '<span class="bg-green-100 text-green-800 text-xs font-bold px-2 py-1 rounded">ត្រឹមត្រូវ</span>';
                    borderClass = 'border-green-300';
                } else {
                    statusBadge = '<span class="bg-red-100 text-red-800 text-xs font-bold px-2 py-1 rounded">ខុស</span>';
                    borderClass = 'border-red-300';
                }

                reviewHtml += `
                    <div class="p-5 border ${borderClass} rounded-xl bg-gray-50">
                        <div class="flex justify-between items-start mb-3">
                            <p class="font-semibold">សំណួរទី ${index + 1}: ${q.question}</p>
                            <div>${statusBadge}</div>
                        </div>
                        <ul class="mb-3 space-y-1">
                `;

                q.options.forEach((opt, optIndex) => {
                    let optStyle = "text-gray-600";
                    if (optIndex === q.answer) {
                        optStyle = "text-green-600 font-bold"; // ចម្លើយត្រូវ
                    } else if (optIndex === userAnswer && !isCorrect) {
                        optStyle = "text-red-600 line-through"; // ចម្លើយសិស្សឆ្លើយខុស
                    }
                    reviewHtml += `<li class="${optStyle}">- ${opt}</li>`;
                });

                reviewHtml += `</ul>`;

                // ឡូជីខលលាក់ដំណោះស្រាយ បើសិស្សមិនបានជ្រើសរើសចម្លើយសោះ
                if (userAnswer === undefined) {
                    reviewHtml += `
                        <div class="mt-3 p-3 bg-yellow-50 rounded-lg text-sm text-yellow-700 border border-yellow-200">
                            <strong>ចំណាំ៖</strong> អ្នកមិនបានជ្រើសរើសចម្លើយទេ។ ដំណោះស្រាយត្រូវបានលាក់ទុក ដើម្បីទុកឱកាសឱ្យអ្នកសាកល្បងគិតម្តងទៀតនៅពេលក្រោយ។
                        </div>`;
                } else {
                    reviewHtml += `
                        <div class="mt-3 p-3 bg-blue-50 rounded-lg text-sm text-blue-800 border border-blue-200">
                            <strong>ដំណោះស្រាយ៖</strong><br> ${q.solution}
                        </div>`;
                }

                reviewHtml += `</div>`;
            });

            document.getElementById('score-display').innerText = `${score} / ${questions.length}`;
            reviewContainer.innerHTML = reviewHtml;
            
            // រៀបចំ MathJax ម្តងទៀតតែសម្រាប់ផ្ទាំងលទ្ធផល
            MathJax.typesetPromise([reviewContainer]);
        }

        // ==================== បម្លែងកាលបរិច្ឆេទជាភាសាខ្មែរ ====================
        function getKhmerDate() {
            const days = ["អាទិត្យ", "ច័ន្ទ", "អង្គារ", "ពុធ", "ព្រហស្បតិ៍", "សុក្រ", "សៅរ៍"];
            const months = ["មករា", "កុម្ភៈ", "មីនា", "មេសា", "ឧសភា", "មិថុនា", "កក្កដា", "សីហា", "កញ្ញា", "តុលា", "វិច្ឆិកា", "ធ្នូ"];
            const d = new Date();
            const dateStr = d.getDate().toString().padStart(2, '0'); // លេខទ្វេ (01, 02...)
            // ដើម្បីបំប្លែងលេខទៅជាលេខខ្មែរ អាចប្រើអនុគមន៍បន្ថែម តែទីនេះខ្ញុំប្រើលេខអារ៉ាប់ដើម្បីងាយស្រួលអាន
            return `ថ្ងៃ${days[d.getDay()]} ទី${dateStr} ខែ${months[d.getMonth()]} ឆ្នាំ${d.getFullYear()}`;
        }
    </script>
</body>
</html>
