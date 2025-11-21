    // Firebase Configuration
    const firebaseConfig = {
        apiKey: "AIzaSyCgWeRM9YppUP6zER1mHxWxxzsMu6ET7MI",
        authDomain: "e-web-e73f4.firebaseapp.com",
        projectId: "e-web-e73f4",
        storageBucket: "e-web-e73f4.firebasestorage.app",
        messagingSenderId: "49194142701",
        appId: "1:49194142701:web:066a7a4240437ee5f935e4",
        measurementId: "G-E36KT28YTQ"
    };

    // Initialize Firebase
    firebase.initializeApp(firebaseConfig);
    const auth = firebase.auth();
    const db = firebase.firestore();

    let isAdmin = false;
    
    // **Committee Sorting Configuration**
    const departmentOrder = {
        "ฝ่ายบริหาร": 1,
        "ฝ่ายเผยแพร่และประชาสัมพันธ์": 2, // แก้ไขชื่อฝ่ายแล้ว
        "ฝ่ายแผนงานและโครงการ": 3,
        "ฝ่ายขับเคลื่อนโครงงาน": 4,
        "ฝ่ายครูที่ปรึกษา": 5
    };

    const positionOrder = {
        "ประธาน": 1,
        "รองประธาน": 2,
        "กรรมการ": 3,
        "กรรมการและเลขานุการ": 4,
        "กรรมการและผู้ช่วยเลขานุการ": 5,
        "ที่ปรึกษา": 6 // เพิ่มที่ปรึกษาเพื่อความยืดหยุ่นหากมีตำแหน่งที่ปรึกษาใน db
    };


// ----------------------------------------------------------------------
// Navigation Functions (แก้ไขเพื่อเพิ่ม URL HASH) 🚀
// ----------------------------------------------------------------------
function showPage(pageId) {
    // 7. (ใหม่) อัปเดต URL Hash โดยใช้ history.pushState เพื่อไม่ให้หน้ากระโดด
    const currentHash = window.location.hash.substring(1);
    if (currentHash !== pageId) {
        history.pushState(null, null, '#' + pageId);
    }
    
    // กำหนดคลาสสำหรับ Mobile Menu
    const mobileActiveClasses = 'text-blue-600 font-semibold bg-blue-100';
    const mobileInactiveClasses = 'text-gray-600 hover:text-gray-900 hover:bg-gray-50';

    // กำหนดคลาสสำหรับ Desktop Menu (nav-btn)
    const desktopActiveClasses = 'text-purple-600 font-semibold border-b-2 border-purple-600'; 
    const desktopInactiveClasses = 'text-gray-600 border-b-2 border-transparent hover:border-gray-300'; 

    // 1. Hide all pages
    document.querySelectorAll('.page').forEach(page => {
        page.classList.add('hidden');
    });
    
    // 2. Show selected page
    const targetPage = document.getElementById(pageId + 'Page');
    if (targetPage) {
        targetPage.classList.remove('hidden');
        targetPage.classList.add('fade-in'); 
    }
    
    // 3. Update navigation - Reset all buttons (Desktop & Mobile)

    // Reset Desktop Buttons (nav-btn) - คาดว่าใน HTML ถูกเปลี่ยนเป็น <a> แล้ว
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.remove(...desktopActiveClasses.split(' '));
        btn.classList.add(...desktopInactiveClasses.split(' '));
    });

    // Reset Mobile Buttons (mobile-nav-btn) - คาดว่าใน HTML ถูกเปลี่ยนเป็น <a> แล้ว
    document.querySelectorAll('.mobile-nav-btn').forEach(btn => {
        btn.classList.remove(...mobileActiveClasses.split(' '));
        btn.classList.add(...mobileInactiveClasses.split(' '));
    });
    
    // 4. Highlight active page button

    // Highlight active buttons (Desktop: nav-btn) โดยใช้ href attribute
    const activeDesktopButton = document.querySelector(`.nav-btn[href="#${pageId}"]`);
    if (activeDesktopButton) {
        activeDesktopButton.classList.remove(...desktopInactiveClasses.split(' '));
        activeDesktopButton.classList.add(...desktopActiveClasses.split(' '));
    }

    // Highlight active buttons (Mobile: mobile-nav-btn) โดยใช้ href attribute
    const activeMobileButton = document.querySelector(`.mobile-nav-btn[href="#${pageId}"]`);
    if (activeMobileButton) {
        activeMobileButton.classList.remove(...mobileInactiveClasses.split(' '));
        activeMobileButton.classList.add(...mobileActiveClasses.split(' '));
    }
    
    // 5. Load page content
    switch(pageId) {
        case 'home':
            loadFeaturedActivities();
            break;
        case 'activities':
            loadActivities();
            break;
        case 'news':
            loadNews();
            break;
        case 'committee':
            loadCommittee();
            break;
        case 'links':
            loadLinks();
            break;
    }
    
    // 6. Hide mobile menu
    document.getElementById('mobileMenu').classList.add('hidden');
    setTimeout(() => { window.scrollTo(0, 0); }, 50);
}

function toggleMobileMenu() {
    const menu = document.getElementById('mobileMenu');
    menu.classList.toggle('hidden');
}
        // Authentication Functions
        function showLoginModal() {
            document.getElementById('loginModal').classList.remove('hidden');
        }

        function hideLoginModal() {
            document.getElementById('loginModal').classList.add('hidden');
            document.getElementById('loginForm').reset();
        }

        function handleLogin(event) {
            event.preventDefault();
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;

            auth.signInWithEmailAndPassword(email, password)
                .then((userCredential) => {
                    isAdmin = true;
                    showAdminPanel();
                    hideLoginModal();
                    showToast('เข้าสู่ระบบสำเร็จ', 'success');
                })
                .catch((error) => {
                    showToast('เข้าสู่ระบบไม่สำเร็จ: ' + error.message, 'error');
                });
        }

        function logout() {
            auth.signOut().then(() => {
                isAdmin = false;
                hideAdminPanel();
                showToast('ออกจากระบบสำเร็จ', 'success');
            });
        }

        function showAdminPanel() {
            document.getElementById('adminPanel').classList.remove('hidden');
            document.getElementById('addActivityBtn').classList.remove('hidden');
            document.getElementById('addNewsBtn').classList.remove('hidden');
            document.getElementById('addMemberBtn').classList.remove('hidden');
            document.getElementById('addLinkBtn').classList.remove('hidden');
        }

        function hideAdminPanel() {
            document.getElementById('adminPanel').classList.add('hidden');
            document.getElementById('addActivityBtn').classList.add('hidden');
            document.getElementById('addNewsBtn').classList.add('hidden');
            document.getElementById('addMemberBtn').classList.add('hidden');
            document.getElementById('addLinkBtn').classList.add('hidden');
        }

        // =========================================================
        // ACTIVITY FUNCTIONS
        // =========================================================

        function showAddActivityModal() {
            document.getElementById('addActivityModal').classList.remove('hidden');
        }

        function hideAddActivityModal() {
            document.getElementById('addActivityModal').classList.add('hidden');
            document.getElementById('addActivityForm').reset();
        }
        
        function showEditActivityModal(id, title, desc, date, featured, url) {
            document.getElementById('editActivityId').value = id;
            document.getElementById('editActivityTitle').value = title;
            document.getElementById('editActivityDescription').value = desc;
            document.getElementById('editActivityDate').value = date;
            document.getElementById('editActivityFeatured').checked = featured;
            document.getElementById('editActivityUrl').value = url || ''; // เพิ่มช่องใส่ลิงก์
            document.getElementById('editActivityModal').classList.remove('hidden');
        }

        function hideEditActivityModal() {
            document.getElementById('editActivityModal').classList.add('hidden');
            document.getElementById('editActivityForm').reset();
        }


        function handleAddActivity(event) {
            event.preventDefault();
            const title = document.getElementById('activityTitle').value;
            const description = document.getElementById('activityDescription').value;
            const date = document.getElementById('activityDate').value;
            const featured = document.getElementById('activityFeatured').checked;
            const url = document.getElementById('activityUrl').value; // ดึงค่าลิงก์

            db.collection('activities').add({
                title: title,
                description: description,
                date: date,
                featured: featured,
                url: url, // บันทึกลิงก์
                createdAt: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                hideAddActivityModal();
                loadActivities();
                loadFeaturedActivities();
                showToast('เพิ่มกิจกรรมสำเร็จ', 'success');
            }).catch((error) => {
                showToast('เกิดข้อผิดพลาด: ' + error.message, 'error');
            });
        }
        
        function handleEditActivity(event) {
            event.preventDefault();
            const id = document.getElementById('editActivityId').value;
            const title = document.getElementById('editActivityTitle').value;
            const description = document.getElementById('editActivityDescription').value;
            const date = document.getElementById('editActivityDate').value;
            const featured = document.getElementById('editActivityFeatured').checked;
            const url = document.getElementById('editActivityUrl').value; // ดึงค่าลิงก์

            db.collection('activities').doc(id).update({
                title: title,
                description: description,
                date: date,
                featured: featured,
                url: url, // อัปเดตลิงก์
                updatedAt: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                hideEditActivityModal();
                loadActivities();
                loadFeaturedActivities();
                showToast('แก้ไขกิจกรรมสำเร็จ', 'success');
            }).catch((error) => {
                showToast('เกิดข้อผิดพลาด: ' + error.message, 'error');
            });
        }

        function loadActivities() {
            db.collection('activities').orderBy('date', 'desc').get().then((querySnapshot) => {
                const activitiesList = document.getElementById('activitiesList');
                activitiesList.innerHTML = '';
                
                querySnapshot.forEach((doc) => {
                    const activity = doc.data();
                    const activityCard = createActivityCard(doc.id, activity);
                    activitiesList.appendChild(activityCard);
                });
            });
        }

        function loadFeaturedActivities() {
            db.collection('activities').where('featured', '==', true).limit(3).get().then((querySnapshot) => {
                const featuredActivities = document.getElementById('featuredActivities');
                featuredActivities.innerHTML = '';
                
                querySnapshot.forEach((doc) => {
                    const activity = doc.data();
                    const activityCard = createFeaturedActivityCard(activity);
                    featuredActivities.appendChild(activityCard);
                });
            });
        }

        function createActivityCard(id, activity) {
            const card = document.createElement('div');
            card.className = 'bg-white shadow-lg rounded-2xl p-6 card-hover transform transition-all duration-300 flex flex-col justify-between';
            
            const editButton = isAdmin ? 
                `<button onclick="showEditActivityModal('${id}', '${activity.title.replace(/'/g, "\\'")}', '${activity.description.replace(/'/g, "\\'")}', '${activity.date}', ${activity.featured}, '${activity.url || ''}')" class="text-sm text-blue-600 hover:text-blue-800 bg-blue-50 px-3 py-1 rounded-full hover:bg-blue-100 transition-all duration-300">แก้ไข</button>` : '';

            const deleteButton = isAdmin ? 
                `<button onclick="deleteActivity('${id}')" class="text-sm text-red-600 hover:text-red-800 bg-red-50 px-3 py-1 rounded-full hover:bg-red-100 transition-all duration-300">ลบ</button>` : '';
                
            const urlButton = activity.url ? 
                `<a href="${activity.url}" target="_blank" rel="noopener noreferrer" class="text-sm text-indigo-600 hover:text-indigo-800 bg-indigo-50 px-3 py-1 rounded-full hover:bg-indigo-100 transition-all duration-300">รายละเอียด/ลงทะเบียน</a>` : '';

            card.innerHTML = `
                <div>
                    <h3 class="text-lg font-bold text-gray-900 mb-3 gradient-text">${activity.title}</h3>
                    <p class="text-base text-gray-600 mb-4 leading-relaxed ">${activity.description}</p>
                    ${activity.featured ? '<span class="inline-block bg-gradient-to-r from-yellow-400 to-orange-500 text-white text-sm px-3 py-1 rounded-full shadow-md">⭐ กิจกรรมเด่น</span>' : ''}
                </div>
                <div class="mt-4 pt-4 border-t border-gray-100">
                    <span class="text-sm text-purple-600 font-medium bg-purple-50 px-3 py-1 rounded-full">${formatDate(activity.date)}</span>
                    <div class="flex flex-wrap gap-2 mt-3">
                        ${urlButton}
                        ${editButton}
                        ${deleteButton}
                    </div>
                </div>
            `;
            return card;
        }

        function createFeaturedActivityCard(activity) {
            const card = document.createElement('div');
            card.className = 'bg-white border border-gray-100 rounded p-4 hover:border-gray-200 transition card-hover';
            card.innerHTML = `
                <h3 class="text-base font-medium text-gray-900 mb-2">${activity.title}</h3>
                <p class="text-sm text-gray-600 mb-3 line-clamp-2">${activity.description}</p>
                <div class="flex justify-between items-center text-xs text-gray-500">
                    <span>${formatDate(activity.date)}</span>
                    ${activity.url ? `<a href="${activity.url}" target="_blank" rel="noopener noreferrer" class="text-indigo-600 hover:text-indigo-800 font-medium">ดูรายละเอียด »</a>` : ''}
                </div>
            `;
            return card;
        }

        function deleteActivity(id) {
            if (confirm('คุณต้องการลบกิจกรรมนี้หรือไม่?')) {
                db.collection('activities').doc(id).delete().then(() => {
                    loadActivities();
                    loadFeaturedActivities();
                    showToast('ลบกิจกรรมสำเร็จ', 'success');
                });
            }
        }

        // =========================================================
        // NEWS FUNCTIONS (ปรับปรุงให้แสดงผลเป็นแบบแผ่นๆ)
        // =========================================================
        
        function showAddNewsModal() {
            document.getElementById('addNewsModal').classList.remove('hidden');
        }

        function hideAddNewsModal() {
            document.getElementById('addNewsModal').classList.add('hidden');
            document.getElementById('addNewsForm').reset();
        }
        
        function showEditNewsModal(id, title, content, date, url) {
            document.getElementById('editNewsId').value = id;
            document.getElementById('editNewsTitle').value = title;
            document.getElementById('editNewsContent').value = content;
            document.getElementById('editNewsDate').value = date;
            document.getElementById('editNewsUrl').value = url || '';
            document.getElementById('editNewsModal').classList.remove('hidden');
        }

        function hideEditNewsModal() {
            document.getElementById('editNewsModal').classList.add('hidden');
            document.getElementById('editNewsForm').reset();
        }

        function handleAddNews(event) {
            event.preventDefault();
            const title = document.getElementById('newsTitle').value;
            const content = document.getElementById('newsContent').value;
            const date = document.getElementById('newsDate').value;
            const url = document.getElementById('newsUrl').value;

            db.collection('news').add({
                title: title,
                content: content,
                date: date,
                url: url,
                createdAt: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                hideAddNewsModal();
                loadNews();
                showToast('เพิ่มข่าวสำเร็จ', 'success');
            }).catch((error) => {
                showToast('เกิดข้อผิดพลาด: ' + error.message, 'error');
            });
        }
        
        function handleEditNews(event) {
            event.preventDefault();
            const id = document.getElementById('editNewsId').value;
            const title = document.getElementById('editNewsTitle').value;
            const content = document.getElementById('editNewsContent').value;
            const date = document.getElementById('editNewsDate').value;
            const url = document.getElementById('editNewsUrl').value;

            db.collection('news').doc(id).update({
                title: title,
                content: content,
                date: date,
                url: url,
                updatedAt: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                hideEditNewsModal();
                loadNews();
                showToast('แก้ไขข่าวสำเร็จ', 'success');
            }).catch((error) => {
                showToast('เกิดข้อผิดพลาด: ' + error.message, 'error');
            });
        }

        function loadNews() {
            db.collection('news').orderBy('date', 'desc').get().then((querySnapshot) => {
                const newsList = document.getElementById('newsList');
                newsList.innerHTML = '';
                
                querySnapshot.forEach((doc) => {
                    const news = doc.data();
                    const newsCard = createNewsCard(doc.id, news);
                    newsList.appendChild(newsCard);
                });
            });
        }

        function createNewsCard(id, news) {
            const card = document.createElement('div');
            // ใช้ class สไตล์เดียวกับ activity card เพื่อให้เป็น "แผ่นๆ"
            card.className = 'bg-white shadow-lg rounded-2xl p-6 card-hover transform transition-all duration-300 flex flex-col justify-between';
            
            const editButton = isAdmin ? 
                `<button onclick="showEditNewsModal('${id}', '${news.title.replace(/'/g, "\\'")}', '${news.content.replace(/'/g, "\\'")}', '${news.date}', '${news.url || ''}')" class="text-sm text-blue-600 hover:text-blue-800 bg-blue-50 px-3 py-1 rounded-full hover:bg-blue-100 transition-all duration-300">แก้ไข</button>` : '';

            const deleteButton = isAdmin ? 
                `<button onclick="deleteNews('${id}')" class="text-sm text-red-600 hover:text-red-800 bg-red-50 px-3 py-1 rounded-full hover:bg-red-100 transition-all duration-300">ลบ</button>` : '';

            const urlButton = news.url ? 
                `<a href="${news.url}" target="_blank" rel="noopener noreferrer" class="text-sm text-indigo-600 hover:text-indigo-800 bg-indigo-50 px-3 py-1 rounded-full hover:bg-indigo-100 transition-all duration-300">ดูรายละเอียดเพิ่มเติม</a>` : '';

            card.innerHTML = `
                <div>
                    <h3 class="text-lg font-bold text-gray-900 mb-3 gradient-text">${news.title}</h3>
                    <p class="text-base text-gray-600 mb-4 leading-relaxed ">${news.content}</p>
                </div>
                <div class="mt-4 pt-4 border-t border-gray-100">
                    <span class="text-sm text-purple-600 font-medium bg-purple-50 px-3 py-1 rounded-full">ประชาสัมพันธ์: ${formatDate(news.date)}</span>
                    <div class="flex flex-wrap gap-2 mt-3">
                        ${urlButton}
                        ${editButton}
                        ${deleteButton}
                    </div>
                </div>
            `;
            return card;
        }

        function deleteNews(id) {
            if (confirm('คุณต้องการลบข่าวนี้หรือไม่?')) {
                db.collection('news').doc(id).delete().then(() => {
                    loadNews();
                    showToast('ลบข่าวสำเร็จ', 'success');
                });
            }
        }
        // =========================================================
        // COMMITTEE FUNCTIONS
        // =========================================================

        function showAddMemberModal() {
            document.getElementById('addMemberModal').classList.remove('hidden');
        }

        function hideAddMemberModal() {
            document.getElementById('addMemberModal').classList.add('hidden');
            document.getElementById('addMemberForm').reset();
        }
        
        function showEditMemberModal(id, name, position, department) {
            document.getElementById('editMemberId').value = id;
            document.getElementById('editMemberName').value = name;
            document.getElementById('editMemberPosition').value = position;
            document.getElementById('editMemberDepartment').value = department;
            document.getElementById('editMemberModal').classList.remove('hidden');
        }
        
        function hideEditMemberModal() {
            document.getElementById('editMemberModal').classList.add('hidden');
            document.getElementById('editMemberForm').reset();
        }

        function handleAddMember(event) {
            event.preventDefault();
            const name = document.getElementById('memberName').value;
            const position = document.getElementById('memberPosition').value;
            const department = document.getElementById('memberDepartment').value;

            db.collection('committee').add({
                name: name,
                position: position,
                department: department,
                createdAt: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                hideAddMemberModal();
                loadCommittee();
                showToast('เพิ่มสมาชิกสำเร็จ', 'success');
            }).catch((error) => {
                showToast('เกิดข้อผิดพลาด: ' + error.message, 'error');
            });
        }
        
        function handleEditMember(event) {
            event.preventDefault();
            const id = document.getElementById('editMemberId').value;
            const name = document.getElementById('editMemberName').value;
            const position = document.getElementById('editMemberPosition').value;
            const department = document.getElementById('editMemberDepartment').value;

            db.collection('committee').doc(id).update({
                name: name,
                position: position,
                department: department,
                updatedAt: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                hideEditMemberModal();
                loadCommittee();
                showToast('แก้ไขสมาชิกสำเร็จ', 'success');
            }).catch((error) => {
                showToast('เกิดข้อผิดพลาด: ' + error.message, 'error');
            });
        }

        function loadCommittee() {
            db.collection('committee').get().then((querySnapshot) => {
                const committeeStructure = document.getElementById('committeeStructure');
                committeeStructure.innerHTML = '';
                
                const departments = {};
                
                querySnapshot.forEach((doc) => {
                    const member = doc.data();
                    if (departmentOrder.hasOwnProperty(member.department)) { 
                        if (!departments[member.department]) {
                            departments[member.department] = [];
                        }
                        departments[member.department].push({id: doc.id, ...member});
                    }
                });
                
                const sortedDeptNames = Object.keys(departments).sort((a, b) => {
                    return departmentOrder[a] - departmentOrder[b];
                });
                
                sortedDeptNames.forEach(dept => {
                    const sortedMembers = departments[dept].sort((a, b) => {
                        const posA = positionOrder[a.position] || 99;
                        const posB = positionOrder[b.position] || 99;
                        return posA - posB;
                    });
                    
                    const deptSection = createDepartmentSection(dept, sortedMembers);
                    committeeStructure.appendChild(deptSection);
                });
            });
        }

        function createDepartmentSection(department, members) {
            const section = document.createElement('div');
            section.className = 'bg-white border border-gray-100 rounded p-4 mb-4 shadow-sm';
            
            let membersHTML = '';
            members.forEach(member => {
                const editButton = isAdmin ? 
                    `<button onclick="showEditMemberModal('${member.id}', '${member.name.replace(/'/g, "\\'")}', '${member.position}', '${member.department}')" class="text-xs text-blue-600 hover:text-blue-800 bg-blue-50 px-2 py-1 rounded-full hover:bg-blue-100 transition-all duration-300">แก้ไข</button>` : '';

                const deleteButton = isAdmin ? 
                    `<button onclick="deleteMember('${member.id}')" class="text-xs text-red-600 hover:text-red-800 bg-red-50 px-2 py-1 rounded-full hover:bg-red-100 transition-all duration-300">ลบ</button>` : '';
                    
                membersHTML += `
                    <div class="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
                        <div>
                            <h4 class="text-base font-medium text-gray-900">${member.name}</h4>
                            <p class="text-sm text-gray-600">${member.position}</p>
                        </div>
                        <div class="flex space-x-2">
                            ${editButton}
                            ${deleteButton}
                        </div>
                    </div>
                `;
            });
            
            section.innerHTML = `
                <h3 class="text-xl font-bold text-gray-900 mb-3 gradient-text">${department}</h3>
                <div class="space-y-1">
                    ${membersHTML}
                </div>
            `;
            
            return section;
        }

        function deleteMember(id) {
            if (confirm('คุณต้องการลบสมาชิกนี้หรือไม่?')) {
                db.collection('committee').doc(id).delete().then(() => {
                    loadCommittee();
                    showToast('ลบสมาชิกสำเร็จ', 'success');
                });
            }
        }

        // =========================================================
        // LINK FUNCTIONS
        // =========================================================
        
        function showAddLinkModal() {
            document.getElementById('addLinkModal').classList.remove('hidden');
        }

        function hideAddLinkModal() {
            document.getElementById('addLinkModal').classList.add('hidden');
            document.getElementById('addLinkForm').reset();
        }

        function showEditLinkModal(id, title, url, description) {
            document.getElementById('editLinkId').value = id;
            document.getElementById('editLinkTitle').value = title;
            document.getElementById('editLinkUrl').value = url;
            document.getElementById('editLinkDescription').value = description || '';
            document.getElementById('editLinkModal').classList.remove('hidden');
        }

        function hideEditLinkModal() {
            document.getElementById('editLinkModal').classList.add('hidden');
            document.getElementById('editLinkForm').reset();
        }

        function handleAddLink(event) {
            event.preventDefault();
            const title = document.getElementById('linkTitle').value;
            const url = document.getElementById('linkUrl').value;
            const description = document.getElementById('linkDescription').value;

            db.collection('links').add({
                title: title,
                url: url,
                description: description,
                createdAt: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                hideAddLinkModal();
                loadLinks();
                showToast('เพิ่มลิงก์สำเร็จ', 'success');
            }).catch((error) => {
                showToast('เกิดข้อผิดพลาด: ' + error.message, 'error');
            });
        }

        function handleEditLink(event) {
            event.preventDefault();
            const id = document.getElementById('editLinkId').value;
            const title = document.getElementById('editLinkTitle').value;
            const url = document.getElementById('editLinkUrl').value;
            const description = document.getElementById('editLinkDescription').value;

            db.collection('links').doc(id).update({
                title: title,
                url: url,
                description: description,
                updatedAt: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                hideEditLinkModal();
                loadLinks();
                showToast('แก้ไขลิงก์สำเร็จ', 'success');
            }).catch((error) => {
                showToast('เกิดข้อผิดพลาด: ' + error.message, 'error');
            });
        }

        function loadLinks() {
            db.collection('links').orderBy('createdAt', 'desc').get().then((querySnapshot) => {
                const linksList = document.getElementById('linksList');
                linksList.innerHTML = '';
                
                querySnapshot.forEach((doc) => {
                    const link = doc.data();
                    const linkCard = createLinkCard(doc.id, link);
                    linksList.appendChild(linkCard);
                });
            });
        }

        function createLinkCard(id, link) {
            const card = document.createElement('div');
            card.className = 'bg-white shadow-xl rounded-2xl p-6 card-hover transform transition-all duration-300 border border-gray-100';
            card.innerHTML = `
                <div class="flex items-start justify-between mb-4">
                    <div class="flex items-center space-x-3">
                        <div class="w-12 h-12 bg-gradient-to-r from-indigo-500 to-purple-600 rounded-full flex items-center justify-center shadow-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"></path>
                            </svg>
                        </div>
                        <div>
                            <h3 class="text-lg font-bold text-gray-900 gradient-text">${link.title}</h3>
                            <p class="text-sm text-gray-500 break-all">${link.url}</p>
                        </div>
                    </div>
                    ${isAdmin ? `
                        <div class="flex space-x-2">
                            <button onclick="showEditLinkModal('${id}', '${link.title.replace(/'/g, "\\'")}', '${link.url}', '${link.description ? link.description.replace(/'/g, "\\'") : ''}')" class="text-sm text-blue-600 hover:text-blue-800 bg-blue-50 px-3 py-1 rounded-full hover:bg-blue-100 transition-all duration-300">แก้ไข</button>
                            <button onclick="deleteLink('${id}')" class="text-sm text-red-600 hover:text-red-800 bg-red-50 px-3 py-1 rounded-full hover:bg-red-100 transition-all duration-300">ลบ</button>
                        </div>
                    ` : ''}
                </div>
                ${link.description ? `<p class="text-base text-gray-600 mb-4 leading-relaxed">${link.description}</p>` : ''}
                <a href="${link.url}" target="_blank" rel="noopener noreferrer" class="inline-flex items-center space-x-2 bg-gradient-to-r from-indigo-500 to-purple-600 text-white px-4 py-2 rounded-lg text-sm hover:from-indigo-600 hover:to-purple-700 transform hover:scale-105 transition-all duration-300 shadow-lg">
                    <span>เยี่ยมชมเว็บไซต์</span>
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path>
                    </svg>
                </a>
            `;
            return card;
        }

        function deleteLink(id) {
            if (confirm('คุณต้องการลบลิงก์นี้หรือไม่?')) {
                db.collection('links').doc(id).delete().then(() => {
                    loadLinks();
                    showToast('ลบลิงก์สำเร็จ', 'success');
                });
            }
        }

        // Utility Functions
        function formatDate(dateString) {
            const date = new Date(dateString);
            return date.toLocaleDateString('th-TH', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
        }

        function showToast(message, type) {
            const toast = document.createElement('div');
            toast.className = `fixed top-4 right-4 px-6 py-3 rounded-lg text-white z-50 ${type === 'success' ? 'bg-green-600' : 'bg-red-600'}`;
            toast.textContent = message;
            document.body.appendChild(toast);
            
            setTimeout(() => {
                toast.remove();
            }, 3000);
        }

        // ----------------------------------------------------------------------
        // Initialize (แก้ไขในส่วนนี้) ✨
        // ----------------------------------------------------------------------
        document.addEventListener('DOMContentLoaded', function() {
            // ตรวจสอบว่ามี Hash ใน URL หรือไม่เมื่อหน้าโหลดครั้งแรก
            const initialHash = window.location.hash.substring(1);
            const defaultPage = 'home';
            
            let pageToLoad = defaultPage;

            // หากมี Hash และ Hash นั้นไม่ใช่ค่าว่าง
            if (initialHash) {
                pageToLoad = initialHash;
            } else {
                // หากไม่มี Hash ให้ใส่ Hash ของหน้าเริ่มต้นใน URL โดยไม่บันทึกประวัติการเข้าชม
                history.replaceState(null, null, '#' + defaultPage);
            }

            showPage(pageToLoad);
            
            // Set today's date as default for date inputs
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('activityDate').value = today;
            document.getElementById('newsDate').value = today;
        });
        
        // (ใหม่) เพิ่ม Event Listener สำหรับปุ่ม Back/Forward ของเบราว์เซอร์
        window.addEventListener('popstate', function(event) {
            const pageHash = window.location.hash.substring(1) || 'home';
            showPage(pageHash);
        });

        // Auth state observer
        auth.onAuthStateChanged((user) => {
            if (user) {
                isAdmin = true;
                showAdminPanel();
                // รีโหลดเนื้อหาเพื่อให้ปุ่มแก้ไขแสดง
                loadActivities();
                loadNews();
                loadCommittee();
                loadLinks();
            } else {
                isAdmin = false;
                hideAdminPanel();
                // รีโหลดเนื้อหาเพื่อซ่อนปุ่มแก้ไข
                loadActivities();
                loadNews();
                loadCommittee();
                loadLinks();
            }
        });
        // ฟังก์ชันสำหรับเปิด Modal
        function showLoginModal() {
            const modal = document.getElementById('loginModal');
            modal.classList.remove('hidden');
            // เพื่อให้ CSS transition ทำงานได้ดี
            setTimeout(() => {
                modal.classList.add('opacity-100');
            }, 10); 
        }

        // ฟังก์ชันสำหรับปิด Modal
        function hideLoginModal() {
            const modal = document.getElementById('loginModal');
            modal.classList.remove('opacity-100');
            // ซ่อนหลังจาก animation เสร็จ
            setTimeout(() => {
                modal.classList.add('hidden');
            }, 300); // 300ms ตรงกับ duration-300 ใน CSS
        }
